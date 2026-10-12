/**
 * version: 20181016
 * 更新及說明：
 *
 *           Date           Author                                                    Description
 *      ==============    ============     ==============================================================================================================
 *        2011/10/13         劉本傑           增加營業人統一編號檢核
 *        2011/10/14         劉本傑           增加檢核是否有輸入全形文字及半形文字
 *        2011/10/28         劉本傑           增加檢核中華民國身份證字號、護照及無戶籍人民身份證號（居留證）
 *        2011/11/09         劉本傑           增加檢核輸入半形及全形的總長度（全形字長度視為 2）
 *        2012/02/02         劉本傑           於 100 年 12 月 27 日，依財政部財稅資料中心，100年 10 月修訂之新規則修改(請參閱附件 6)
 *                                            < http://www.fdc.gov.tw/public/Attachment/1121511411571.pdf >
 *                                            See com.cathay.common.util.Id java code for detail. 修改 validation.checkROCID、validation.checkROCARC
 *        2013/03/02         劉本傑           因應資料遮蔽檢討作業所轉置 ID，進行調整
 *        2017/08/29         黃亮?           加入金門電話檢核，區碼為082，號碼為九碼
 *        2017/10/16         黃亮?           因應domain開放及擴充，移除checkEmail針對最後最後一個domain進行需要為二或三碼
 *        2018/03/20         劉本傑           增加檢核中華民國無戶籍人民稅籍編號（舊制統一證號）
 *        2020/04/13		 謝孟儒			因應移民署新政策，新增統一證號規則與舊制並行
 *        2021/07/13         劉長軒           112年新制營利事業統一編號由「可被10整除」改為「可被5整除」
 *
 *           public function                                                        Description
 *      ================================   =============================================================================================================
 *        validation.checkUniSN               營業人統一編號檢核
 *        validation.hasFullType              檢核是否有輸入全形文字
 *        validation.hasHalfType              檢核是否有輸入半形文字
 *        validation.checkROCID               檢核中華民國身份證字號
 *        validation.checkROCPassport         檢核中華民國護照
 *        validation.checkROCARC              檢核中華民國無戶籍人民身份證號（居留證）
 *        validation.checkID                  檢查證件「中華民國護照及中華民國無戶籍人民身份證號（居留證）」
 *        validation.checkInputLength         檢核輸入半形及全形的總長度（全形字長度視為 2）
 *        validation.checkROCOLDARC           檢核中華民國無戶籍人民稅籍編號（舊制統一證號）
 *
 **/
if(!window.validation || !window.validation.checkUniSN){
	validation = new function(){

	    // ---------- 「統一編號」相關 ----------

		// 營業人統一編號八碼各自的乘數
		var uniSNMultiple = [ 1, 2, 1, 2, 1, 2, 4, 1 ];

		// ---------------------------------------------------------

		// ---------- 「國民身分證統一編號、居留證檢查」相關 ----------

		// 正常的字母順序表
		var alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

		// 依公佈之字母對應數值，個位數乘以 9 加上十位數後，除以 10 所得之餘數的對應表
		var modInt = [1, 0, 9, 8, 7, 6, 5, 4, 9, 3, 2, 2, 1, 0, 8, 9, 8, 7, 6, 5, 4, 3, 1, 3, 2, 0];

		// 公佈之字母對應數值之個位數對應表
		var digitInt = [0, 1, 2, 3, 4, 5, 6, 7, 4, 8, 9, 0, 1, 2, 5, 3, 4, 5, 6, 7, 8, 9, 2, 0, 1, 3];

		// 驗証時各指定的乘數
		var mulInt = [1, 8, 7, 6, 5, 4, 3, 2, 1];
		
		var convertNumMapping = "PDKOAFNCLJQRMBEGHSIX";

		//2020-04-09 配合移民署政策
		//新制各字母對應之數字
		var alphabetMappingDigit = [10, 11, 12, 13, 14, 15, 16, 17, 34, 18, 19, 20, 21, 22, 35, 23, 24, 25, 26, 27, 28, 29, 32, 30, 31, 33];

		//2020-04-09 配合移民署政策
		//新制驗証時各指定的乘數
		var mulIntNew = [ 1, 9, 8, 7, 6, 5, 4, 3, 2, 1 ];


		// 計算國民身分証、居留證、旅行證號是否符合邏輯
		/**
		 *	@private
		 *	@class 計算國民身分証、居留證、旅行證號是否符合邏輯
		 *	@param id (String)
		 *	@param tmpStr (String)
		 *	@return String
		 *	@author 劉本傑
		 *	@version 1.00
		 **/
		function checkSum(id, tmpStr){

			var lastChar = id.charAt(id.length - 1);
			if (isNaN(lastChar)) {
				return false;
			}

			//最後一碼為檢查碼
			var chkCode = parseInt(lastChar, 10);
			var sum = 0;
			//2020-04-10 配合移民署政策
			if('89'.indexOf(id.charAt(1)) != -1){
				//依各乘數計算和
				for(var i=0; i<10; i++){
					var currChar = tmpStr.charAt(i);
					if (isNaN(currChar)) {
						return false;
					}
					sum += (parseInt(currChar) * mulIntNew[i]) % 10;
				}	
			}else{
				//依各乘數計算和
				for(var i=0; i<9; i++){
					var currChar = tmpStr.charAt(i);
					if (isNaN(currChar)) {
						return false;
					}
					sum += (parseInt(currChar) * mulInt[i]);
				}	
			}

			//取餘數
			var mod = sum % 10;

			//驗証補數
			return (mod == 0 && chkCode == 0) || (mod + chkCode == 10);
		}

		/**
		 *	@private
		 *	@class 轉換至檢核的 ID
		 *	@param inputId (String) : 身分證號碼
		 *	@return String
		 *	@author 劉本傑
		 *	@version 1.00
		 **/
		function convertCheckId(inputId){
			inputId = inputId.toUpperCase();
			var lastWrodIndex = inputId.length - 1;
			var lastWord = inputId.charAt(lastWrodIndex);
			var num = convertNumMapping.indexOf(lastWord);
			if (num >= 0) {
				return null;
			}
			return inputId;
		}

	    // ---------------------------------------------------------

		return {
			/**
			 *	@public
			 *	@class 營業人統一編號檢核
			 *	@param str (String) : 營業人統一編號
			 *	@return boolean
			 *	@author 劉本傑
			 *	@version 1.00
			 **/
		    checkUniSN:function(str) {

				// 輸入參數不可為空值且長度共八位
				if(typeof(str) == 'undefined' || str ==null || str =='' || str.length != 8){
					return false;
				}

		        // 組成驗證用的號碼字串
		        var intValue = 0;

		        // 傳入參數的第 7 碼的數字是否為 7
		        var position7Is7 = false;

		        for (var i = 0; i < str.length; i++) {

		            var strTempCharAt = str.charAt(i);

		            // 全部為數字型態
		            if (isNaN(strTempCharAt)) {
		                return false;
		            }

					var num = parseInt(strTempCharAt, 10);

		            // 判斷第 7 碼的數字是否為 7
		            if (i == 6 && num == 7) {
		                position7Is7 = true;
		            }

		            // 每個數字  × 乘數
		            var multiplyNumber = num * uniSNMultiple[i];

		            // 取得個位數（即 10 的餘數）
		            var remainderByTen = multiplyNumber % 10;

		            intValue += remainderByTen;

		            // 取得十位數
		            intValue += (multiplyNumber - remainderByTen) / 10;

		        }

		        // 若能被  5 整除，表示營業人統一編號正確
		        var isValidate = intValue % 5 == 0;
		        if (!isValidate && position7Is7) {
		            intValue += 1;
		            isValidate = intValue % 5 == 0;
		        }

		        return isValidate;
		    },
			/**
			 *	@public
			 *	@class 檢核是否有輸入全形文字
			 *	@param str (String) : 輸入文字
			 *	@return boolean
			 *	@author 劉本傑
			 *	@version 1.00
			 **/
			hasFullType:function(str){
		    	var arr = str.match(/[^\x00-\xff]/g);
		    	return arr!=null && arr.length>0;
		    },
			/**
			 *	@public
			 *	@class 檢核是否有輸入半形文字
			 *	@param str (String) : 輸入文字
			 *	@return boolean
			 *	@author 劉本傑
			 *	@version 1.00
			 **/
			hasHalfType:function(str){
		    	var arr = str.match(/[\x00-\xff]/g);
		    	return arr!=null && arr.length>0;
		    },
			/**
			 *	@public
			 *	@class 檢核輸入半形及全形的總長度（全形字長度視為 2）
			 *	       Ex : validation.checkInputLength('12345', 5)            return true。
			 *	            validation.checkInputLength('一二123', 5)          return false。
			 *	            validation.checkInputLength('一二123', 7)          return true
			 *	            validation.checkInputLength('一二123', 7, 1)       return false。
			 *	            validation.checkInputLength('一二123', 7, 2)       return true。
			 *	            validation.checkInputLength('一二123', 7, 3, 2)    return false。
			 *	@param str (String) : 輸入文字
			 *	@param len (int) : 總長度
			 *	@param fullLen (int) : 全型字總長度（此為選項，可不輸入）
			 *	@param halfLen (int) : 半型字總長度（此為選項，可不輸入）
			 *	@return boolean
			 *	@author 劉本傑
			 *	@version 1.00
			 **/
			checkInputLength:function(str, len, fullLen, halfLen){

				if(isNaN(len)){
					return true;
				}

				var checkLength = function(inputLen, limitLen){
					if(limitLen && !isNaN(limitLen) && limitLen>0 && inputLen>limitLen){
						return false;
					}
					return true;
				}

				var fullWordArray = str.match(/[^\x00-\xff]/g);
				var halfWordArray = str.match(/[\x00-\xff]/g);

				var fullWordLength = fullWordArray==null?0:fullWordArray.length;
				var halfWordLength = halfWordArray==null?0:halfWordArray.length;

				if(!checkLength(fullWordLength, fullLen)){
					return false;
				}

				if(!checkLength(halfWordLength, halfLen)){
					return false;
				}

				if(fullWordLength*(window.charCountsByte || 2)+halfWordLength>len){
					return false;
				}

				return true;
			},
			/**
			 *	@public
			 *	@class 檢核中華民國身份證字號
			 *	@param str (String)
			 *	@return boolean
			 *	@author 劉本傑
			 *	@version 1.00
			 **/
		    checkROCID:function(strID) {

				// 輸入參數不可為空值且長度共 10 碼
				if(typeof(strID) == 'undefined' || strID == null || strID == '' || strID.length != 10){
					return false;
				}

				strID = convertCheckId(strID);
				if (strID === null) {
					return true;
				}

		        var letterIndex = alphabet.indexOf(strID.charAt(0));

				if(letterIndex == -1){
					return false;
				}
				
				//2020-04-10 配合移民署政策
				 if ("89".indexOf(strID.charAt(1)) >= 0) {
		            return false;
		        }

				var intNum = modInt[letterIndex];

				var tmpStr = '' + intNum + strID.substring(1, 10);

				return checkSum(strID, tmpStr);

		    },
			/**
			 *	@public
			 *	@class 檢核中華民國護照
			 *	@param str (String)
			 *	@return boolean
			 *	@author 劉本傑
			 *	@version 1.00
			 **/
		    checkROCPassport:function(str) {
		        // 第2碼性別碼
		        if ("12".indexOf(str.substring(1, 2)) < 0) {
		            return false;
		        }
		        return true;
		    },
		    /**
			 *	@public
			 *	@class 檢核中華民國無戶籍人民身份證號（居留證）
			 *	@param str (String)
			 *	@return boolean
			 *	@author 劉本傑
			 *	@version 1.00
			 **/
		    checkROCARC:function(strID) {

				// 輸入參數不可為空值且長度共 10 碼
				if(typeof(strID) == 'undefined' || strID ==null || strID =='' || strID.length != 10){
					return false;
				}

				strID = convertCheckId(strID);
				if (strID === null) {
					return true;
				}

				var letterIndex = alphabet.indexOf(strID.charAt(0));
				var secondIndex = alphabet.indexOf(strID.charAt(1));
				//2020-04-10 配合移民署政策
				var newRuleSecondIndex = '89'.indexOf(strID.charAt(1));

				if(letterIndex == -1 || (secondIndex == -1 && newRuleSecondIndex == -1)){
					return false;
				}

				var tmpStr = '';
				//轉換為數列
				if(newRuleSecondIndex != -1){
					var intNum = alphabetMappingDigit[letterIndex];
					tmpStr = '' + intNum + strID.substring(1, 10);
				}else{
					var intNum = modInt[letterIndex];
					var intNum2 = digitInt[secondIndex];
					tmpStr = '' + intNum + intNum2 + strID.substring(2, 10);
				}
				return checkSum(strID, tmpStr);

			},
            /**
             *  @public
             *  @class 檢核中華民國無戶籍人民稅籍編號（舊制統一編號）
             *         稅籍編號共十碼（YYYYMMDDXX），其編碼規則為
             *         前八碼（YYYYMMDD）為護照內之西元出生年月日（例如：1979/06/30，則為 19790630）
             *         後兩碼（XX）為護照內英文姓名第一個字（不論姓或名）之前二個英文字母（例如：RANDY LIPE 則為 RA；KIN YEO YAP 則為 KI；CHEN, SHU HWA 則為 CH）
             *         以上述範例，則其稅籍編號為 19790630RA
             *  @param str (String)
             *  @return boolean
             *  @author 劉本傑
             *  @version 1.00
             **/
            checkROCOLDARC:function(strID) {

                // 輸入參數不可為空值且長度共 10 碼
                if(typeof(strID) == 'undefined' || strID ==null || strID =='' || strID.length != 10){
                    return false;
                }
                
                strID = convertCheckId(strID);
                if (strID === null) {
                    return true;
                }
                
                var preStr = strID.substring(0, 8);
                if(!isADdate(preStr)){
                    return false;
                }
                
                var letter8Index = alphabet.indexOf(strID.charAt(8));
                var letter9Index = alphabet.indexOf(strID.charAt(9));

                if(letter8Index < 0 || letter9Index < 0){
                    return false;
                }

                return true;


            },
			/**
			 *	@public
			 *	@class 檢查證件
			 *	         1.檢核中華民國身份證字號
			 *	         2.檢核中華民國無戶籍人民身份證號（居留證）
			 *	@param str (String)
			 *	@return boolean
			 *	@author 劉本傑
			 *	@version 1.00
			 **/
		    checkID:function(str) {
				// 輸入參數不可為空值且長度共 10 碼
				if(typeof(str) == 'undefined' || str ==null || str =='' || str.length != 10){
					return false;
				}
				// 第 2 碼為性別碼
				var gender = "ABCD".indexOf(str.charAt(1));
				//2020-04-09 配合移民署新政策
				var newGender = "89".indexOf(str.charAt(1));
				return ((gender >= 0) || (newGender >= 0))?validation.checkROCARC(str):validation.checkROCID(str);
		    }
		};

	};

}

/*
 * 程式：validate.js檢核JS utility
 * 作者：新契約小組
 * 功能：提供各項的validate檢核
 * 完成：2004/03/30
 * showMessage(msg)			:顯示訊息for validate.js
 * getYear()				:取得現在日期－年
 * getMonth()				:取得現在日期－月
 * getDay()		        	:取得現在日期－日
 * idCheck(id)				:證件檢核(use idCheck1,2,3)
 * idCheck1(id)				:身分證號檢核
 * idCheck2(id)				:護照檢核
 * idCheck3(id)				:外國人身分證號檢核
 * setTabIndex(field, index):設定欄位TabIndex
 * initFocus(){		        :將游標停留在第一個輸入欄位
 * reSetTabIndex(field)		:重新設定TabIndex
 * validateRequired(form) 	:檢查欄位必須輸入
 * validateLength(form) 	:檢查欄位長度
 * validateCreditCard(form) :檢查信用卡卡號
 * validateEmail(form) 		:檢查Email格式
 * validateMask(form) 		:自訂檢查規則
 * validateInteger(form) 	:檢查是否為正整數
 * validateIntegerFloat(form)   :檢查是否為正浮點數(含小數點)
 * validateCheck(form) 		:檢查輸入格式是否正確
 * validateDate(form) 		:檢查日期格式
 * validateQueryKey(form) 	:檢查修改資料是否是查詢的那一筆
 * validateAddress(form) 	:檢查地址格式
 * validateId(form) 		:檢查身分證護照格式(formx.FORCE.value為強迫輸入非合理證件號碼請輸入Y，沒有強迫就給'')
 * validateID(form) 		:檢查身分證護照格式
 * validatePassPost(form) 	:檢查護照格式
 * validateFmode(form) 		:檢查是否為全形格式
 * validateUnitedNo(form) 	:檢查統一編號檢核
 * validatePolicyNo(form) 	:檢查保單號碼
 * white(form)              : reload頁面時，將所有欄位去除反白
 * validateValueRange(formx,JSHashMap)：檢查欄位輸入值是否正確
 * validateTime(formx)      :檢查時間輸入是否正確 >> hhmmss
 * iscmpid(id)              :統一編號檢核
 * isPolicyNo(policy_no)	:保單號碼檢核
 * isBig5(str)				:判斷是否為 Big5 有效字
 * checkYMD(str)			:檢核 西元年 YYYY-MM-DD
 **/

// * 940513 春成 setTabIndex僅適用text,passowrd,textarea，修正validateRequired(formx)使用時機
//2005-09-26 laycf 增加 判斷是否為 Big5 有效字 >> isBig5(str)
//							更新validateFmode(form)增加判斷是否為 Big5 有效字
//2006-04-18 laycf 更新將isBig5中的index設為var以免影響外部變數
//2006-05-03 laycf 修改潤年是用西元年判斷並非用民國年

/**
 * 功能說明 :reload頁面時，將所有欄位去除反白。 <br>
 * 更新：2004/04/28 -- 杜青蓉
 **/
function white(formx){
	var leng = formx.elements.length;
     for (i=0;i<leng;i++){
          if (formx.elements[i].type=="text" || formx.elements[i].type=="textarea" ){
	  		  formx.elements[i].style.backgroundColor='#FFFFFF'
           }
      }
}

/*
 *	顯示錯誤訊息的位置及方式。 <br>
 * 	有錯誤訊息時會alert在畫面上。 <br>
 */
function showMessage(msg) {
	var showMssg, re;			     // 宣告變數。
	var ss = ""+msg+"";				 // 取得錯誤訊息的字串
	re = /,/g;						 // 建立通用運算式模式。
	showMssg = ss.replace(re, "\n");    //用 "" 取代","。
	alert(showMssg);
}

var date = new Date();
var YearMonth;
var upMonth;
var today;

/**
 * 功能說明 : 取得年。 <br>
 */
function getYear(){
	var year = date.getFullYear()-1911;
    return year;
}

/*
 * 功能說明 : 取得月。 <br>
 * 使用說明 : 如果是個位數會自動補 0。 <br>
 */
function getMonth(){
	var month = date.getMonth()+1;
    month < 10 ? month = "0" + month:month = "" + month;
    return month;
}

/*
 * 功能說明 : 取得日。 <br>
 * 使用說明 : 如果是個位數會自動補 0。 <br>
 */
function getDay(){
	var day = date.getDate();
    day < 10 ? day = "0" + day:day = "" + day;
    return day;
}

function idCheck(id){
	return validation.checkID(id);
}

//檢查身分證
function idCheck1(id){
	return validation.checkROCID(id);
}

/**
 *	功能說明 : 護照檢查。 <br>
 *	使用說明 :  <br>
 *  1.第一碼為* <br>
 *  2.第二碼為性別碼(1或2)。 <br>
 *  3.第三碼後為護照號碼，完全不檢核<br>
 *　2004/03/31盧春成－增加。 <br>
 */
function idCheck2(id){
	var sId=id.toUpperCase();
	if(sId.length<3) return false;
	if(sId.charAt(0)!='*') return false;
	var a=1;
	var b;
	b=sId.charAt(a);
	if (b==1 || b ==2) 	return true;
	else return false ;
}

//檢查居留證
function idCheck3(id){
	return validation.checkROCARC(id);
}

function idCheck4(id){
	var sId=id.toUpperCase();
	if (sId.length==0 || sId.length>20) return false;
	for (var i = 0 ; i < sId.length ; i++) {
		var code1 = escape(sId.charAt(i)).toString();
		var code2 = sId.charCodeAt(i);
		if((code1.length!=6) &&((91>code2 && code2>64) || (58>code2 && code2>47))){
			continue;
		}
		return false;
  	}
	return true;
}

/*
*功能說明：檢核護照　2004/10/07盧春成－新增
*使用方式：
*	formx = document.formx;
*	this.aa = new Array("varname", "error message", new Function ("varName", "this.force=''; return this[varName];"));
*/
function validatePassPost(form) {
	var strId ="";
	var isError = false;
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oId = new Pass_Number();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oId) {
		strId = form[oId[x][0]].value;
    	form[oId[x][0]].style.backgroundColor='#FFFFFF';
		isError = false;
		if (strId != '') {
			if (!idCheck2(strId)) {
				isError = true;
			}
			if (isError) {
		    	form[oId[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oId[x][0]];
		 		ei++;
		 		setTabIndex(form[oId[x][0]], ei);
	     		fields[i++] = oId[x][1];
	     		bValid = false;
	     	}
	    }
	}
	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/*
 * 功能說明 : 設定欄位TabIndex。 <br>
 **/
var lastField = "";
var lastTabIndex = "";
function setTabIndex(field, index) {
	var x;
	if ( typeof(field) == "string" ) {
		x = document.getElementById(field);

		if(!x){
			var eles = document.getElementsByName(field);
			if(eles.length > 0){
				x = eles[0];
			}
		}
	} else if( typeof(field) == "object" ) {
		x = field;
		lastField = x.name;
		lastTabIndex = index;
		if (x==null) {
			return false;
		}
		x.tabIndex = index ;
	}
	if ( index == "1001" ) {
		x.select();
	}
}

/**
 * 功能說明 : 自動 focus 第一個輸入欄位。 <br>
 **/
function initFocus(){
	for (i=0;i<document.forms[0].length ;i++ )
 	{
        if (document.forms[0].elements[i].type=="text" && document.forms[0].elements[i].tabIndex != "-1"){
			document.forms[0].elements[i].select();
			document.forms[0].elements[i].focus();
			break;
		}
	}
}

/**
 * 功能說明 : 重新設定 tabIndex 。 <br>
 * 使用說明 : 如果有 readOnly 會跳過。 <br>
 */
function reSetTabIndex(field){
    var si = 1;
	var end ;
	if (field!=undefined)
	{
		lastField = field;
		eval("document.forms[0]."+field+".focus()");
	}

	for (i=0;i<document.forms[0].length ;i++ ) {
		if (document.forms[0].elements[i].name==lastField) {
			end = i ;
			for (end ; end <document.forms[0].length ; end++ ) {
				if (document.forms[0].elements[end].readOnly==false)
				{
					lastTabIndex ++;
					setTabIndex(document.forms[0].elements[end], lastTabIndex);
				}
			}
		} else {
			if (document.forms[0].elements[i].type=="button") {
				si ++;
				setTabIndex(document.forms[0].elements[i], si);
			}
		}
	}
	return true;
}

/**
 * 功能說明 : 檢查欄位必須輸入。 <br>
 * 使用說明 :  <br>
 * function required () {  <br>
 *     this.aa = new Array("Name", "姓名 欄位請勿空白.", new Function ("varName", " return this[varName];")); <br>
 * } <br>
 * 注意事項 : 當有多筆欄位需要做檢核時  <br>
 * this.aa ~ az  -> 不可以都一樣必須要不同可以用英文做排列 <br>
 * this.ba ~ bz <br>
 * this.ca ~ cz  <br>
 **/
function validateRequired(form) {
	var bValid = true;
    var focusField = null;
    var i = 0;
    var fields = new Array();
    oRequired = new required();
	lastField = "";
	lastTabIndex = "";
    var ei = 1000;
	for (x in oRequired) {
    	//先將欄位顏色回復
		form[oRequired[x][0]].style.backgroundColor='#FFFFFF';
		if ((form[oRequired[x][0]].type == 'text' || form[oRequired[x][0]].type == 'textarea' || form[oRequired[x][0]].type == 'select-one' || form[oRequired[x][0]].type == 'radio' || form[oRequired[x][0]].type == 'password') && form[oRequired[x][0]].value == '' && form[oRequired[x][0]].disabled != true ) {
    		// 這是新增的功能，主要顯示錯誤的欄位，用紅色來區分。
			form[oRequired[x][0]].style.backgroundColor='#FF8888';
			if (i == 0) {focusField = form[oRequired[x][0]];}
			ei++;
			//春成 940513 修正 setTabIndex 只適用text,password,textarea
			//setTabIndex(form[oRequired[x][0]], ei);
			if ((form[oRequired[x][0]].type == 'text' || form[oRequired[x][0]].type == 'textarea'  || form[oRequired[x][0]].type == 'password') && form[oRequired[x][0]].value == '' && form[oRequired[x][0]].disabled != true ) {
				setTabIndex(form[oRequired[x][0]], ei);
			}
	    	fields[i++] = oRequired[x][1];
	    	bValid = false;
		}
	}
	if (fields.length > 0) {
		// 這是新增功能，主要功能是顯示錯誤訊息。
		showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/**
 * 功能說明 : 檢查欄位必須輸入。 <br>
 * 使用說明 :  <br>
 * function required () {  <br>
 *     this.aa = new Array("Name", "姓名 欄位請勿空白.", new Function ("varName", " return this[varName];")); <br>
 * } <br>
 * 注意事項 : 當有多筆欄位需要做檢核時  <br>
 * this.aa ~ az  -> 不可以都一樣必須要不同可以用英文做排列 <br>
 * this.ba ~ bz <br>
 * this.ca ~ cz  <br>
 * 與validateRequired差別在於oRequired = new required(form)呼叫時會帶入form
 **/
function validateRequiredAT(form) {
	var bValid = true;
    var focusField = null;
    var i = 0;
    var fields = new Array();
    oRequired = new required(form);
	lastField = "";
	lastTabIndex = "";
    var ei = 1000;
	for (x in oRequired) {
    	//先將欄位顏色回復
		form[oRequired[x][0]].style.backgroundColor='#FFFFFF';
		if ((form[oRequired[x][0]].type == 'text' || form[oRequired[x][0]].type == 'textarea' || form[oRequired[x][0]].type == 'select-one' || form[oRequired[x][0]].type == 'radio' || form[oRequired[x][0]].type == 'password') && form[oRequired[x][0]].value == '' && form[oRequired[x][0]].disabled != true ) {
    		// 這是新增的功能，主要顯示錯誤的欄位，用紅色來區分。
			form[oRequired[x][0]].style.backgroundColor='#FF8888';
			if (i == 0) {focusField = form[oRequired[x][0]];}
			ei++;
			//春成 940513 修正 setTabIndex 只適用text,password,textarea
			//setTabIndex(form[oRequired[x][0]], ei);
			if ((form[oRequired[x][0]].type == 'text' || form[oRequired[x][0]].type == 'textarea'  || form[oRequired[x][0]].type == 'password') && form[oRequired[x][0]].value == '' && form[oRequired[x][0]].disabled != true ) {
				setTabIndex(form[oRequired[x][0]], ei);
			}
	    	fields[i++] = oRequired[x][1];
	    	bValid = false;
		}
	}
	if (fields.length > 0) {
		// 這是新增功能，主要功能是顯示錯誤訊息。
		showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/**
 * 功能說明：新增統編當要保人，檢查欄位輸入格式是否正確，給成立件修正畫面用。  <br>
 * 使用方法： <br>
 * this.aa = new Array("varmane", "error message", new Function ("varName", "this.check=/U10/;  return this[varName];")); <br>
 **/
function validateCheckAT(form) {
 	var bValid = true;
    var focusField = null;
    var i = 0;
    var fields = new Array();
    oCheck = new check();
    var ei = 1000;
	lastTabIndex = "";
    for (x in oCheck) {
    	if (oCheck[x][0] == 'A_ID'){
	        if ((form[oCheck[x][0]].type == 'text' || form[oCheck[x][0]].type == 'textarea' || form[oCheck[x][0]].type == 'password') && form[oCheck[x][0]].value.length > 0) {
				form[oCheck[x][0]].style.backgroundColor='#FFFFFF';
				if (!matchCheckAT(form[oCheck[x][0]].value.substring(2,10), oCheck[x][2]("check"))) {
					form[oCheck[x][0]].style.backgroundColor='#FF8888';
					if (i == 0) focusField = form[oCheck[x][0]];
					ei++;
					setTabIndex(form[oCheck[x][0]], ei);
					fields[i++] = oCheck[x][1];
					bValid = false;
				}
	        }
    	}else{
            if ((form[oCheck[x][0]].type == 'text' || form[oCheck[x][0]].type == 'textarea' || form[oCheck[x][0]].type == 'password') && form[oCheck[x][0]].value.length > 0) {
    			form[oCheck[x][0]].style.backgroundColor='#FFFFFF';
    			if (!matchCheck(form[oCheck[x][0]].value, oCheck[x][2]("check"))) {
    				form[oCheck[x][0]].style.backgroundColor='#FF8888';
    				if (i == 0) focusField = form[oCheck[x][0]];
    				ei++;
    				setTabIndex(form[oCheck[x][0]], ei);
    				fields[i++] = oCheck[x][1];
    				bValid = false;
    			}
            }
    	}
    }
    if (fields.length > 0) {
		showMessage(fields);
		reSetTabIndex();
    }
    return bValid;
}

/**
 * 功能說明 : 檢查 字元長度。 <br>
 * 使用說明 : <br>
 * function length(){ <br>
 *     this.aa = new Array("file", "欄位名稱，請輸入正確的字元長度.", new Function ("varName", "this.length=6;  return this[varName];")); <br>
 * } <br>
 *  <br>
 * this.length=6 -> 指欄位必須要輸入6個字元 <br>
 **/
function validateLength(form) {
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	var ei = 1000;

	oLength = new length();
	for (x in oLength) {
		if ((form[oLength[x][0]].type == 'text' ||
			 form[oLength[x][0]].type == 'textarea' ||
			 form[oLength[x][0]].type == 'password') &&
			(form[oLength[x][0]].value.length > 0)) {
	    	//先將欄位顏色回復
			form[oLength[x][0]].style.backgroundColor='#FFFFFF';
			if (!matchLength(form[oLength[x][0]].value, oLength[x][2]("length"))) {
				form[oLength[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) {focusField = form[oLength[x][0]];}
				ei++;
			    setTabIndex(form[oLength[x][0]], ei);
				fields[i++] = oLength[x][1];
				bValid = false;
			}
		}
	}
	if (fields.length > 0) {
		// 這是新增功能，主要功能是顯示錯誤訊息。
		showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

function matchLength(value, length) {
   if (value.length != length) {
	   return false;
   }
   return true;
}

/**
 * 功能說明：檢查信用卡號是否有效。 <br>
 * 使用方式： <br>
 * this.aa = new Array("varname", "卡號 此信用卡號無效 .<br>", new Function ("varName", " return this[varName];")); <br>
 **/
function validateCreditCard(form) {
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oCreditCard = new creditCard();
	var ei=1000;
	for (x in oCreditCard) {
		if ((form[oCreditCard[x][0]].type == 'hidden' || form[oCreditCard[x][0]].type == 'text' || form[oCreditCard[x][0]].type == 'textarea' || form[oCreditCard[x][0]].type == 'select-one' || form[oCreditCard[x][0]].type == 'radio') && form[oCreditCard[x][0]].value.length > 0) {
        	//先將欄位顏色回復
			form[oCreditCard[x][0]].style.backgroundColor='#FFFFFF';
			if (!luhnCheck(form[oCreditCard[x][0]].value)) {
				form[oCreditCard[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) {focusField = form[oCreditCard[x][0]];}
				ei++;
				setTabIndex(form[oCreditCard[x][0]],ei);
				fields[i++] = oCreditCard[x][1];
				bValid = false;
			}
		}
	}
    if (fields.length > 0) {
		// 這是新增功能，主要功能是顯示錯誤訊息。
		showMessage(fields);
		reSetTabIndex();
    }
    return bValid;
}

/**
 * Reference: http://www.ling.nwu.edu/~sburke/pub/luhn_lib.pl。 <br>
 **/
function luhnCheck(cardNumber) {
	if (isLuhnNum(cardNumber)) {
    	var no_digit = cardNumber.length;
        var oddoeven = no_digit & 1;
        var sum = 0;
        for (var count = 0; count < no_digit; count++) {
            var digit = parseInt(cardNumber.charAt(count));
            if (!((count & 1) ^ oddoeven)) {
                digit *= 2;
                if (digit > 9) digit -= 9;
            }
            sum += digit;
        }
        if (sum == 0) return false;
        if (sum % 10 == 0) return true;
    }
    return false;
}


function isLuhnNum(argvalue) {
	argvalue = argvalue.toString();
    if (argvalue.length == 0) return false;
    for (var n = 0; n < argvalue.length; n++) {
		if (argvalue.substring(n, n+1) < "0" || argvalue.substring(n,n+1) > "9") {
			return false;
		}
	}
    return true;
}

/**
 * 功能說明：檢查eMail輸入是否正確。 <br>
 * 使用方式： <br>
 * this.aa = new Array("varname", "error message", new Function ("varName","this.emailStr=^\S+@\S+\.\S+&", "return this[varName];")); <br>
 **/
function validateEmail(form) {
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oEmail = new email();
	var ei=1000;
    for (x in oEmail) {
		if ((form[oEmail[x][0]].type == 'text' || form[oEmail[x][0]].type == 'textarea') && form[oEmail[x][0]].value.length > 0) {
	    	//先將欄位顏色回復
			form[oEmail[x][0]].style.backgroundColor='#FFFFFF';
			if (!checkEmail(form[oEmail[x][0]].value)) {
				// 這是新增的功能，主要顯示錯誤的欄位，用紅色來區分。
				form[oEmail[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) {focusField = form[oEmail[x][0]];}
				ei++;
				setTabIndex(form[oEmail[x][0]],ei);
				fields[i++] = oEmail[x][1];
				bValid = false;
			}
		}
    }
	if (fields.length > 0) {
    	// 這是新增功能，主要功能是顯示錯誤訊息。
		showMessage(fields);
		reSetTabIndex();
    }
    return bValid;
}

/**
 * 檢查eMail是否正確
 **/
function checkEmail(emailStr) {
	if (emailStr.length == 0) return true;
	var emailPat=/^(.+)@(.+)$/;
	var specialChars="\\(\\)<>@,;:\\\\\\\"\\.\\[\\]";
	var validChars="\[^\\s" + specialChars + "\]";
	var quotedUser="(\"[^\"]*\")";
	var ipDomainPat=/^(\d{1,3})[.](\d{1,3})[.](\d{1,3})[.](\d{1,3})$/;
	var atom=validChars + '+';
	var word="(" + atom + "|" + quotedUser + ")";
	var userPat=new RegExp("^" + word + "(\\." + word + ")*$");
	var domainPat=new RegExp("^" + atom + "(\\." + atom + ")*$");
	var matchArray=emailStr.match(emailPat);

	if (matchArray == null){
		return false;
	}

	var user=matchArray[1];
	var domain=matchArray[2];

	if (user.match(userPat) == null){
		return false;
	}

	var IPArray = domain.match(ipDomainPat);
   	if (IPArray != null) {
		for (var i = 1; i <= 4; i++) {
			if (IPArray[i] > 255) return false;
		}
		return true;
	}

	var domainArray=domain.match(domainPat);
	if (domainArray == null) return false;

	var atomPat=new RegExp(atom,"g");
	var domArr=domain.match(atomPat);
	var len=domArr.length;

	if (len < 2) {
		return false;
	}
	return true;
}

/**
 * 功能說明 : 。 <br>
 * 使用說明 : 可以自定檢查規則 , 所以只要把正規檢查的語法放到 this.mask 裡面就可以。 <br>
 * function mask () {  <br>
 *	this.aa = new Array("No", "請輸填 1 到 6 . <br>", new Function ("varName", "this.mask=/^[1-6]*$/;  return this[varName];"));	    	     <br>
 *	this.ab = new Array("No", "請勿輸入特殊字元 . <br>", new Function ("varName", "this.mask=/^[0-9a-zA-Z]*$/;  return this[varName];"));	    	     <br>
 *	this.ac = new Array("No", "欄位請勿輸入數字 . <br>", new Function ("varName", "this.mask=/^[0-9]*$/;  return this[varName];")); <br>
 *	this.ad = new Array("No", "欄位請輸入數字 . <br>", new Function ("varName", "this.mask=/^[a-zA-Z]*$/;  return this[varName];"));	    	     <br>
 * } <br>
 **/
function validateMask(form) {
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oMasked = new mask();
	var ei = 1000;
	lastTabIndex = "";
	for (x in oMasked) {
		if ((form[oMasked[x][0]].type == 'text' || form[oMasked[x][0]].type == 'textarea' || form[oMasked[x][0]].type == 'password') && form[oMasked[x][0]].value.length > 0) {
        	//先將欄位顏色回復
			form[oMasked[x][0]].style.backgroundColor='#FFFFFF';
			if (!matchPattern(form[oMasked[x][0]].value, oMasked[x][2]("mask"))) {
				// 這是新增的功能，主要顯示錯誤的欄位，用紅色來區分。
				form[oMasked[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oMasked[x][0]];
				ei++;
				setTabIndex(form[oMasked[x][0]], ei);
				fields[i++] = oMasked[x][1];
				bValid = false;
			}
		}
	}
	if (fields.length > 0) {
	// 這是新增功能，主要功能是顯示錯誤訊息。
	  showMessage(fields);
	  reSetTabIndex();
	}
	return bValid;
}
/**
 *  <br>
 **/
function matchPattern(value, mask) {
	var bMatched = mask.exec(value);
	if(!bMatched) return false;
	return true;
}

/**
 * 功能說明：檢查輸入是否為正數字(不含小數)。  <br>
 * 使用方式： <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "return this[varName];")); <br>
 **/
function validateInteger(form) {
	var bValid = true;
    var focusField = null;
    var i = 0;
    var fields = new Array();
    oInteger = new IntegerValidations();
    //2004/02/19林秉毅－修改TabIndex由1000開始起跳
	var ei=1000;
    for (x in oInteger) {
    	if ((form[oInteger[x][0]].type == 'text' || form[oInteger[x][0]].type == 'textarea' || form[oInteger[x][0]].type == 'select-one' || form[oInteger[x][0]].type == 'radio') && form[oInteger[x][0]].value.length > 0) {
        	//先將欄位顏色回復
			form[oInteger[x][0]].style.backgroundColor='#FFFFFF';
        	//檢核數字欄位
   			var s=form[oInteger[x][0]].value
			var s3=s+"_";	//避免　var a=5000 進入檢核不到
			var intError = 0;
			for (j = 0; j < s3.length-1; j++)
		    {
		    	c = s3.charCodeAt(j);
		     	if (c<48 || c>57) intError++;
		    }
			if (intError>0) {
				// 這是新增的功能，主要顯示錯誤的欄位，用紅色來區分。
				form[oInteger[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) {focusField = form[oInteger[x][0]];}
				ei++;
				setTabIndex(form[oInteger[x][0]],ei);
				fields[i++] = oInteger[x][1];
				bValid = false;
           }
        }
    }
    if (fields.length > 0) {
		showMessage(fields);
		reSetTabIndex();
    }
    return bValid;
}

/**
 * 功能說明：檢查輸入是否為數字(含小數)。  <br>
 * 使用方式： <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "return this[varName];")); <br>
 **/
function validateIntegerFloat(form) {
    var bValid = true;
    var focusField = null;
    var i = 0;
    var fields = new Array();
    fInteger = new validateIntegerFloats();
	var ei = 1000;
    for (x in fInteger) {
		if ((form[fInteger[x][0]].type == 'text' || form[fInteger[x][0]].type == 'textarea' || form[fInteger[x][0]].type == 'select-one' || form[fInteger[x][0]].type == 'radio') && form[fInteger[x][0]].value.length > 0) {
			form[fInteger[x][0]].style.backgroundColor='#FFFFFF';
			if (isNaN(form[fInteger[x][0]].value)) {
	              form[fInteger[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) {focusField = form[fInteger[x][0]];}
				ei++;
				setTabIndex(form[fInteger[x][0]], ei);
				fields[i++] = fInteger[x][1];
				bValid = false;
			}
			var iValue = parseFloat(form[fInteger[x][0]].value);
			if (!iValue || !(iValue >= -2147483648 && iValue <= 2147483647)) {
				form[fInteger[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) {focusField = form[fInteger[x][0]];}
				ei++;
				setTabIndex(form[fInteger[x][0]], ei);
				fields[i++] = fInteger[x][1];
				bValid = false;
			}
		}
    }
    if (fields.length > 0) {
		showMessage(fields);
		reSetTabIndex();
    }
    return bValid;
}

/**
 * 功能說明：檢查欄位輸入格式是否正確。  <br>
 * 使用方法： <br>
 * this.aa = new Array("varmane", "error message", new Function ("varName", "this.check=/U10/;  return this[varName];")); <br>
 **/
function validateCheck(form) {
 	var bValid = true;
    var focusField = null;
    var i = 0;
    var fields = new Array();
    oCheck = new check();
    var ei = 1000;
	lastTabIndex = "";
    for (x in oCheck) {
        if ((form[oCheck[x][0]].type == 'text' || form[oCheck[x][0]].type == 'textarea' || form[oCheck[x][0]].type == 'password') && form[oCheck[x][0]].value.length > 0) {
			form[oCheck[x][0]].style.backgroundColor='#FFFFFF';
			if (!matchCheck(form[oCheck[x][0]].value, oCheck[x][2]("check"))) {
				form[oCheck[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oCheck[x][0]];
				ei++;
				setTabIndex(form[oCheck[x][0]], ei);
				fields[i++] = oCheck[x][1];
				bValid = false;
			}
        }
    }
    if (fields.length > 0) {
		showMessage(fields);
		reSetTabIndex();
    }
    return bValid;
}

/**
 *  <br>
 **/
function matchCheck(value, check) {
    if (check=/U10/) {
		if(idCheck(value)==false) return (false);
    }
	return true;
}

/**
 * 功能說明：檢查輸入之日期格式是否正確。  <br>
 * 使用方法： <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "this.datePatternStrict='yyMMdd';  return this[varName];")); <br>
 **/
function validateDate(form) {

	if(typeof(form) == 'string'){
		return validateDateInput(form);
	}

	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oDate = new DateValidations();
	var ei = 1000;
	lastTabIndex = "";
	for (x in oDate) {
		var value = form[oDate[x][0]].value;
		if (value.length == 6){
			value = "0"+value;
		}
		var datePattern = oDate[x][2]("datePatternStrict");
		var isError = false;
		if ((form[oDate[x][0]].type == 'text' || form[oDate[x][0]].type == 'textarea') && value.length > 0 && datePattern.length > 0) {
			form[oDate[x][0]].style.backgroundColor='#FFFFFF';
			var MONTH = "MM";
			var DAY = "dd";
			var YEAR = "yyy";

			var orderMonth = datePattern.indexOf(MONTH);
			var orderDay = datePattern.indexOf(DAY);
			var orderYear = datePattern.indexOf(YEAR);

			if ((orderMonth > orderYear && orderMonth < orderDay)) {
				var iDelim1 = orderYear + YEAR.length;
				var iDelim2 = orderMonth + MONTH.length;
				var delim1 = datePattern.substring(iDelim1, iDelim1 + 1);
				var delim2 = datePattern.substring(iDelim2, iDelim2 + 1);

				if (iDelim1 == orderMonth && iDelim2 == orderDay) {
					dateRegexp = new RegExp("^(\\d{3})(\\d{2})(\\d{2})$");
				} else if (iDelim1 == orderMonth) {
					dateRegexp = new RegExp("^(\\d{3})(\\d{2})[" + delim2 + "](\\d{2})$");
				} else if (iDelim2 == orderDay) {
					dateRegexp = new RegExp("^(\\d{3})[" + delim1 + "](\\d{2})(\\d{2})$");
				} else {
					dateRegexp = new RegExp("^(\\d{3})[" + delim1 + "](\\d{2})[" + delim2 + "](\\d{2})$");
				}

		        var matched = dateRegexp.exec(value);

        		if(matched != null) {
					if (!isValidDate(matched[3], matched[2], matched[1])) {
			        	isError = true;
					}
				} else {
        			isError = true;
        		}
	        } else {
	        	isError = true;
			}	//	if ((orderMonth > orderYear && orderMonth < orderDay)) {
			if (isError) {
				form[oDate[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oDate[x][0]];
				ei++;
				setTabIndex(form[oDate[x][0]], ei);
				fields[i++] = oDate[x][1];
				bValid =  false;
			}
		}	//		if ((form[oDate[x][0]].type == 'text' || form[oDate[x][0]].type == 'textarea') && value.length > 0 && datePattern.length > 0) {
	}	//	for (x in oDate) {
	if (fields.length > 0) {
		showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

function validateDateInput(v) {
	v = v.replace('/','');
	v = v.replace('-','');
	v = v.replace('/','');
	v = v.replace('-','');
	var data = v.match(/^(\d{4})(\d{2})(\d{2})$/);
	if (!data || !v) {
		return false;
	}
	var d = new Date(RegExp.$1 + "/" + RegExp.$2 + "/" + RegExp.$3);
	if (d.getMonth() != (RegExp.$2-1) || d.getDate() != RegExp.$3) {
		return false;
	}
	return true;
}

/**
 * 檢核是否為有效日期。 <br>
 **/
function isValidDate(day, month, year) {
	strToday = getYear() + getMonth() + getDay() ;
	strInput = year + month + day;
	// 檢查月份。
	if (month < 1 || month > 12) return false;
	// 檢查日期。
   	if (day < 1 || day > 31) return false;
	// 檢查沒有31日的月份。
	if ((month == 4 || month == 6 || month == 9 || month == 11) && day == 31) return false;
	// 檢查2月份的日期。
	if (month == 2) {
		//2006-05-03 laycf 修改潤年是用西元年判斷並非用民國年
		if (year.substring(0,1) == '0'){
			year = year.substring(1,3);
		}
		year = parseInt(year)+1911;
		var leap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
		if (day>29 || (day == 29 && !leap)) return false;
	}
	return true;
}

/**
 * 功能說明：檢核查詢與修改的資料是否為同一筆。  <br>
 * 使用方式： <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "return this[varName];")); <br>
 **/
function validateQueryKey(form) {
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oKey = new queryKeys();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oKey) {
		//判斷當初查詢資料與修改的資料是否相同
		if (form[oKey[x][0]].value != form["K_"+oKey[x][0]].value) {
	    	form[oKey[x][0]].style.backgroundColor='#FF8888';
			if (i == 0) focusField = form[oKey[x][0]];
	 		ei++;
	 		setTabIndex(form[oKey[x][0]], ei);
     		fields[i++] = oKey[x][1];
     		bValid = false;
	    }
	}
	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}
/**
 * 功能說明：檢核地址格式。  <br>
 * 使用方式： <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "return this[varName];")); <br>
 **/
function validateAddress(form) {
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oAddress = new address();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oAddress) {
    	form[oAddress[x][0]].style.backgroundColor='#FFFFFF';
    	if (form[oAddress[x][0]].value.length>0) {
	    	//開始檢核地址格式
			var isCounty=0,isCity=0,isVillage=0,isArea=0,isRoad=0,isNo=0;
			var s = form[oAddress[x][0]].value;
			var intError=0;
			for (var j=0 ; j < s.length ; j++)
			{
				isCounty+=s.charAt(j)=="縣" ? 1:0;
				isCity+=s.charAt(j)=="市" ? 1:0;
				isVillage+=s.charAt(j)=="鄉" ? 1:0;
				isVillage+=s.charAt(j)=="鎮" ? 1:0;
				isVillage+=s.charAt(j)=="市" ? 1:0;
				/*因有些地址還是沒有村里路街巷，
				isRoad+=s.charAt(j)=="村" ? 1:0;
				isRoad+=s.charAt(j)=="里" ? 1:0;
				isRoad+=s.charAt(j)=="路" ? 1:0;
				isRoad+=s.charAt(j)=="街" ? 1:0;
				isRoad+=s.charAt(j)=="巷" ? 1:0;
				*/
				isNo+=s.charAt(j)=="號" ? 1:0;
			}
			//有縣就有鄉鎮市或只有直轄市
			if (isCounty>0){if(isVillage<1) intError++;}
			else {if(isCity<1) intError++;}
			//if (isRoad<1){ intError++;}
			if (isNo<1) { intError++;}
			//若有錯誤
			if (intError>0) {
		    	form[oAddress[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oAddress[x][0]];
		 		ei++;
		 		setTabIndex(form[oAddress[x][0]], ei);
	     		fields[i++] = oAddress[x][1];
	     		bValid = false;
		    }
		}
	}
	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/*
*功能說明：檢核國內身分證檢查　2004/10/07盧春成－新增
*使用方式：
*	formx = document.formx;
*	this.aa = new Array("varname", "error message", new Function ("varName", "this.force=''; return this[varName];"));
*/
//2020-04-14 DJ業務有使用, ID_Number()物件在各自頁面自行定義, 參考範例請參照DJA20600
function validateID(form) {
	var strId ="";
	var isError = false;
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oId = new ID_Number();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oId) {
		strId = form[oId[x][0]].value;
    	form[oId[x][0]].style.backgroundColor='#FFFFFF';
		isError = false;
		if (strId != '') {
			if (!idCheck1(strId)) {
				isError = true;
			}
			if (isError) {
		    	form[oId[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oId[x][0]];
		 		ei++;
		 		setTabIndex(form[oId[x][0]], ei);
	     		fields[i++] = oId[x][1];
	     		bValid = false;
	     	}
	    }
	}
	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/**
 * 功能說明：檢核ID。  <br>
 * 使用方式： <br>
 * formx = document.formx; <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "this.force=''; return this[varName];")); <br>
 * this.ab = new Array("varname", "error message", new Function ("varName", "this.force='"+formx.FORCE.value+"'; return this[varName];")); <br>
 * formx.FORCE.value為強迫輸入非合理證件號碼請輸入Y，沒有強迫就給''  <br> <br>
 * 2004/03/31林秉毅－新增 <br>
 * 2005/02/21盧春成－強迫碼，第二碼需許A,B,C,D
 **/
//2020-04-14 AT業務有使用, checkId()物件在各自頁面自行定義, 參考範例請參照ATA90100
function validateId(form) {
	var strId ="";
	var isError = false;
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oId = new checkId();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oId) {
		strId = form[oId[x][0]].value;
    	form[oId[x][0]].style.backgroundColor='#FFFFFF';
		//非強迫且有資料需檢查ID合理性
		isError = false;
		if (strId != '') {
			if (oId[x][2]("force")=='Y') {
				//若為強迫碼則應為長度１０且第一碼應介於A~Z,第二碼應為１或２
				if (strId.length!=10) {
					isError = true;
				} else if (strId.charCodeAt(0)>90 || strId.charCodeAt(0)< 65) {
					isError = true;
				} else {
					var s2=strId.charAt(1);
					//2020-04-14 新增第二碼為8or9的檢核
					if (s2!=1 && s2!=2 && s2!=A && s2!=B && s2!=C && s2!=D && s2!=8 && s2!=9) isError = true;
				}
			} else if (!idCheck(strId)) {
				isError = true;
			}
			if (isError) {
		    	form[oId[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oId[x][0]];
		 		ei++;
		 		setTabIndex(form[oId[x][0]], ei);
	     		fields[i++] = oId[x][1];
	     		bValid = false;
	     	}
	    }
	}
	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/**
 * 功能說明：檢核全形格式。  <br>
 * 使用方式： <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "return this[varName];"));  <br>
 * <br>
 * 2004/04/01杜青蓉－新增 <br>
 **/
function validateFmode(form) {
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oFmode = new checkFmode();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oFmode) {
		strValue = form[oFmode[x][0]].value;
    	form[oFmode[x][0]].style.backgroundColor='#FFFFFF';
    	if (strValue.length>0) {
	    	//開始檢核地址格式
			var tbyte;
			var intError=0;
			for (var i=0 ; i < strValue.length ; i++) {
				tbyte=strValue.charCodeAt(i);
				if (tbyte >= 0 && tbyte <= 255) intError++;
			}
			//若有錯誤
			if (intError>0) {
		    	form[oFmode[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oFmode[x][0]];
		 		ei++;
		 		setTabIndex(form[oFmode[x][0]], ei);
	     		fields[i++] = oFmode[x][1];
	     		bValid = false;
		    }
			//2005-09-26 laycf 增加判斷是否為big5碼
			else{
				if (!isBig5(strValue)){
			    	form[oFmode[x][0]].style.backgroundColor='#FF8888';
					if (i == 0) focusField = form[oFmode[x][0]];
			 		ei++;
			 		setTabIndex(form[oFmode[x][0]], ei);
		     		fields[i++] = oFmode[x][1];
		     		bValid = false;
				}
			}
		}
	}
	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/**
 * 功能說明：輸入值範圍檢核。  <br>
 * 使用方式： <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "this.range='0-6'; return this[varName];")); <br>
 * <br>
 * 2004/05/11杜青蓉－新增 <br>
 **/
function validateValueRange(form) {
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oValue = new valueRange();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oValue) {
		strValue = form[oValue[x][0]].value;
		strFieldName = oValue[x][0];
		valueCheck=oValue[x][2]("range");
    	form[oValue[x][0]].style.backgroundColor='#FFFFFF';
    	if (strValue != "" ) {
	    	if(!checkRange(strValue,valueCheck)){
	    		form[oValue[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oValue[x][0]];
				ei++;
				setTabIndex(form[oValue[x][0]], ei);
				fields[i++] = oValue[x][1];
				bValid = false;
	    	}
		}
	}
	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/**
 * <br>
 *
 **/
function checkRange(value,strCheck){
	var beNum=Number(strCheck.substring(0,1));
	var endNum=Number(strCheck.substring(2));

	//2006-12-13
	//alert(value);
	//若輸入的值不為數字回傳錯誤
	re = /\d/;

	if (!re.test(value)){

		return false;

	}

	var num=Number(value);
	if( (num < beNum) || (num > endNum)){
		return false;
	}
	return true;
}

/**
 * 功能說明：時間輸入格式檢查。  <br>
 * 使用方式： <br>
 * this.aa = new Array('fieldName','error message',new Function('varName','return this[varName];')); <br>
 *  <br>
 *  -- 2004/07/05 杜青蓉 <br>
 **/
function validateTime(form) {
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oValue = new checkTime();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oValue) {
		strValue = form[oValue[x][0]].value;

		strFieldName = oValue[x][0];
    	form[oValue[x][0]].style.backgroundColor='#FFFFFF';
    	if (strValue != "" ) {
	    	if(!checkTimeInput(strValue)){
	    		form[oValue[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oValue[x][0]];
				ei++;
				setTabIndex(form[oValue[x][0]], ei);
				fields[i++] = oValue[x][1];
				bValid = false;
	    	}
		}
	}

	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/**
 *  <br>
 **/
function checkTimeInput(inputvalue){
		var isOK=true;
		var hh,mm,ss;
		if(inputvalue.length != 4 && inputvalue.length != 6){
			isOK=false;
		}else if(isNaN(inputvalue)){
			isOK = false;
		}else if(inputvalue.indexOf(":") != -1 && inputvalue.indexOf(".") != -1){
			isOK = false;
		}else{
			if(inputvalue.length == 6){
				hh=Number(inputvalue.substring(0,2));
				mm=Number(inputvalue.substring(2,4));
				ss=Number(inputvalue.substring(4));
				if(((hh <0 || hh >23) & (mm <0 || mm>59) &(ss < 0 || ss>59))){
					isOK=false;
				}
			}else if(inputvalue.length == 4){
				hh=Number(inputvalue.substring(0,2));
				mm=Number(inputvalue.substring(2));

				if((hh <0 || hh >23) || (mm <0 || mm>59) ){
					isOK=false;
				}
			}
		}
		return isOK;
}
/**
 * 功能說明 : 統一編號檢查。  <br>
 * <br>
 * 李燕雪－增加 <br>
 * 2006/01/18吳明憲－修改 <br>
 **/
function iscmpid(id) {
	var pa=[1,2,1,2,1,2,4,1];
	var nSum=0;
	if (id.length!=8) return false;
	for(i=0; i<id.length; i++) {
		var tp=parseInt(id.substr(i,1))*pa[i];
		nSum+=Math.floor(tp/10)+tp%10;
    }
	return (nSum%5==0) || (nSum%5==4 && id.substr(6,1)=="7");
}
/**
 * 功能說明：檢核統一編號。  <br>
 * 使用方式： <br>
 * formx = document.formx; <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "this.force=''; return this[varName];")); <br>
 * <br>
 * 2004/10/07盧春成－新增 <br>
 **/
function validateUnitedNo(form) {
	var strId ="";
	var isError = false;
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oId = new UnitedNo();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oId) {
		strId = form[oId[x][0]].value;
    	form[oId[x][0]].style.backgroundColor='#FFFFFF';
		isError = false;
		if (strId != '') {
			if (!iscmpid(strId)) {
				isError = true;
			}
			if (isError) {
		    	form[oId[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oId[x][0]];
		 		ei++;
		 		setTabIndex(form[oId[x][0]], ei);
	     		fields[i++] = oId[x][1];
	     		bValid = false;
	     	}
	    }
	}
	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/**
 * 功能說明 : 保單號碼檢查。  <br>
 * 保單號碼規則有變時，請同步修改java版 com.cathay.at.z0.module.ATZ0_B005
 **/
function isPolicyNo(policy_no)
{
if (policy_no == null) return false;
//判斷保單號碼長度10 & 數字
if (policy_no.length == 10 && !isNaN(policy_no) )
  {
   TOTAL = policy_no.substr(0,1) * 4 + policy_no.substr(1,1) * 3 + policy_no.substr(2,1) * 2 + policy_no.substr(3,1) * 7 + policy_no.substr(4,1) * 6 + policy_no.substr(5,1) * 5 + policy_no.substr(6,1) * 4 + policy_no.substr(7,1) * 3 + policy_no.substr(8,1) * 2 ;

   Y = TOTAL % 11;
   if  (Y == 0  || Y == 1)
       { if  (J = "0")
             return true;
         else
             return false;
       }
   else
       { if   (policy_no.substr(9,1) == 11 - Y)
              return true;
         else
              return false;
       }
  }
  else
  { return false; }

}

/**
 * 功能說明：保單號碼檢查。  <br>
 * 使用方式： <br>
 * formx = document.formx; <br>
 * this.aa = new Array("varname", "error message", new Function ("varName", "this.force=''; return this[varName];")); <br>
 * <br>
 * 2005/04/13盧春成－新增 <br>
 **/
function validatePolicyNo(form) {
	var strId ="";
	var isError = false;
	var bValid = true;
	var focusField = null;
	var i = 0;
	var fields = new Array();
	oId = new PolicyNo();
	lastField = "";
	lastTabIndex = "";
	var ei = 1000;
	for (x in oId) {
		strId = form[oId[x][0]].value;
    	form[oId[x][0]].style.backgroundColor='#FFFFFF';
		isError = false;
		if (strId != '') {
			if (!isPolicyNo(strId)) {
				isError = true;
			}
			if (isError) {
		    	form[oId[x][0]].style.backgroundColor='#FF8888';
				if (i == 0) focusField = form[oId[x][0]];
		 		ei++;
		 		setTabIndex(form[oId[x][0]], ei);
	     		fields[i++] = oId[x][1];
	     		bValid = false;
	     	}
	    }
	}
	if (fields.length > 0) {
	    showMessage(fields);
		reSetTabIndex();
	}
	return bValid;
}

/**
 * 功能說明：判斷是否為 Big5 有效字。  <br>
 * 2005/09/26 laycf －新增 <br>
 **/

var big5FilterCodes = {};
function isBig5(str, isAlert){

	var code = big5FilterCodes['codes'];
	if(!code){
	//*************************** 所有非big5有效字的unicode碼(int) **************************
		code = new Array();
	//< 20000
		code[0] = new Array(19970,19972,19973,19974,19986,19987,19991,19994,19995,19996,19997,20000);
	// 20000 - 20500
		code[1] = new Array( 20001,20002,20003,20004,20005,20007,20008,20009,20010,20012,20015,20020,20021,20022,20023,20026,20029,20030,20031,20032,20033,20036,20038,20041,20042,20044,20048,20049,20052,20053,20055,20058,20059,20064,20065,20066,20067,20068,20069,20070,20071,20072,20074,20075,20076,20077,20078,20079,20080,20081,20082,20084,20085,20086,20087,20088,20089,20090,20091,20092,20093,20096,20097,20101,20103,20105,20106,20111, 20112,20118,20119,20120,20122,20124,20125,20128,20131,20135,20137,20138,20143,20144,20145,20146,20148,20149,20151,20152,20155,20156,20157,20158,20159,20165,20172,20174,20175,20176,20177,20178,20179,20187,20192,20194,20198,20199,20202,20203,20204,20205,20206,20207,20216,20217,20218,20220,20222,20227,20230,20231,20236,20246,20247,20250,20251,20252,20254,20255,20256,20257,20259,20260,20261,20262,20263,20264,20265,20266,20267,20270,20273,20274,20277,20279,20281,20288,20290,20292,20293,20298,20299,20325,20326,20328,20333,20337,20338,20362,20364,20366,20371,20377,20383,20384,20385,20386,20387,20388,20389,20390,20391,20392,20393,20394,20395,20396,20397,20400,20401,20404,20408,20412,20413,20414,20422,20424,20428,20434,20437,20450,20451,20452,20453,20454,20455,20456,20457,20458,20459,20461,20464,20466,20473,20475,20476,20477,20479,20481,20482,20483,20484,20488,20490,20496);
	//20500 - 21000
		code[2] = new Array( 20509,20516,20526,20530,20532,20534,20536,20537,20538,20539,20541,20542,20543,20546,20548,20560,20562,20564,20566,20568,20569,20582,20583,20588,20593,20600,20601,20603,20604,20606,20607,20609,20612,20614,20616,20617,20618,20623,20624,20627,20631,20639,20640,20641,20644,20645,20646,20647,20648,20649,20650,20651,20665,20668,20672,20675,20684,20685,20688,20690,20696,20697,20700,20702,20703,20705,20706,20715,20722,20724,20727,20730,20732,20737,20749,20750,20751,20758,20761,20763,20765,20766,20771,20775,20776,20779,20780,20783,20790,20798,20802,20810,20814,20815,20816,20817,20819,20822,20824,20832,20836,20838,20842,20847,20848,20850,20851,20852,20857,20858,20859,20861,20862,20863,20865,20866,20867,20868,20869,20870,20872,20875,20876,20878,20880,20886,20889,20890,20891,20892,20893,20895,20897,20899,20902,20903,20904,20905,20907,20909,20910,20911,20914,20915,20916,20917,20920,20922,20923,20927,20928,20929,20930,20931,20935,20937,20943,20945,20946,20947,20949,20950,20953,20954,20955,20959,20962,20963,20964,20965,20966,20967,20968,20969,20970,20971,20972,20973,20974,20975,20978,20980,20983,20987,20988,20990,20991,20994,20996,20997);
	//21000 - 21500
		code[3] = new Array( 21003,21005,21007,21012,21013,21016,21017,21018,21019,21023,21024,21026,21027,21030,21031,21035,21036,21037,21039,21044,21049,21052,21053,21054,21055,21056,21058,21061,21064,21071,21072,21073,21075,21079,21080,21081,21088,21091,21092,21093,21094,21095,21096,21104,21105,21107,21110,21113,21118,21125,21126,21134,21135,21136,21138,21140,21141,21146,21148,21149,21150,21153,21154,21156,21157,21159,21160,21167,21168,21169,21170,21171,21172,21173,21174,21175,21176,21177,21178,21181,21183,21188,21189,21190,21192,21194,21195,21196,21198,21199,21200,21201,21204,21210,21212,21216,21217,21221,21223,21224,21226,21228,21229,21230,21234,21238,21241,21245,21248,21249,21250,21251,21252,21255,21260,21267,21268,21272,21275,21278,21284,21285,21286,21287,21288,21289,21291,21292,21294,21298,21299,21301,21302,21304,21306,21307,21314,21318,21323,21326,21327,21328,21333,21334,21336,21337,21339,21341,21343,21346,21348,21349,21351,21352,21353,21354,21355,21357,21364,21366,21370,21373,21374,21376,21377,21379,21381,21382,21383,21384,21385,21387,21388,21389,21392,21393,21395,21397,21403,21408,21409,21410,21411,21414,21416,21417,21418,21419,21422,21423,21424,21425,21427,21429,21430,21431,21432,21434,21436,21437,21438,21439,21440,21441,21442,21444,21445,21446,21447,21452,21454,21455,21456,21457,21458,21459,21461,21464,21465,21466,21468,21469,21470,21472,21479,21492,21494,21495,21497,21498);
	//21500 - 22000
		code[4] = new Array( 21501,21502,21503,21504,21506,21509,21523,21524,21525,21526,21527,21530,21537,21538,21539,21551,21554,21556,21562,21567,21572,21577,21579,21580,21581,21584,21585,21586,21587,21589,21590,21591,21592,21593,21594,21595,21596,21597,21598,21599,21609,21610,21613,21614,21625,21635,21637,21641,21642,21647,21651,21652,21655,21657,21659,21660,21661,21662,21663,21667,21668,21682,21684,21685,21689,21706,21707,21708,21709,21712,21713,21714,21715,21716,21717,21719,21720,21721,21722,21723,21724,21725,21727,21731,21740,21743,21744,21748,21749,21750,21753,21758,21760,21762,21773,21779,21781,21782,21784,21785,21787,21788,21789,21790,21791,21792,21793,21794,21795,21796,21797,21800,21801,21803,21818,21821,21823,21826,21831,21833,21836,21843,21844,21848,21849,21850,21851,21853,21856,21863,21864,21865,21867,21868,21869,21870,21871,21872,21873,21874,21875,21876,21880,21881,21882,21893,21894,21904,21910,21911,21915,21918,21920,21929,21935,21936,21940,21942,21943,21944,21945,21946,21948,21949,21950,21953,21975,21976,21982,21984,21994,21995,21996,21997,21998,22000);
	//22000 - 22500
		code[5] = new Array( 22001,22003,22004,22005,22008,22011,22019,22021,22023,22026,22027,22033,22040,22041,22042,22046,22048,22049,22050,22051,22052,22053,22054,22056,22059,22061,22065,22071,22076,22083,22084,22087,22091,22093,22095,22096,22097,22098,22100,22101,22102,22107,22108,22109,22111,22113,22119,22133,22138,22139,22140,22141,22152,22153,22154,22155,22161,22162,22164,22166,22171,22174,22175,22176,22177,22178,22179,22180,22185,22191,22192,22193,22200,22201,22202,22203,22207,22212,22215,22222,22223,22224,22226,22229,22230,22232,22233,22236,22242,22243,22246,22248,22249,22252,22253,22255,22257,22258,22259,22260,22261,22262,22264,22267,22268,22269,22270,22272,22277,22278,22286,22287,22288,22289,22293,22295,22297,22301,22305,22308,22309,22310,22311,22315,22321,22322,22325,22326,22327,22328,22329,22330,22332,22333,22335,22338,22339,22340,22342,22344,22355,22356,22357,22358,22359,22360,22361,22362,22363,22364,22365,22366,22367,22368,22371,22373,22375,22380,22382,22392,22393,22394,22398,22399,22401,22404,22405,22406,22407,22408,22409,22410,22413,22414,22416,22417,22418,22422,22428,22433,22438,22439,22440,22441,22442,22443,22444,22445,22447,22448,22449,22450,22451,22452,22455,22459,22462,22464,22468,22469,22472,22473,22474,22477,22481,22483,22486,22487,22488,22489,22490,22491,22493,22494);
	//22500 - 23000
		code[6] = new Array( 22502,22504,22506,22507,22511,22526,22527,22531,22543,22545,22546,22547,22549,22550,22551,22552,22554,22559,22562,22566,22571,22586,22588,22590,22592,22593,22594,22595,22596,22597,22598,22599,22608,22614,22620,22623,22624,22625,22630,22631,22633,22634,22636,22638,22640,22642,22643,22647,22648,22660,22668,22669,22674,22677,22678,22679,22681,22682,22683,22690,22692,22695,22698,22701,22704,22706,22708,22709,22710,22711,22712,22713,22720,22723,22724,22730,22731,22732,22733,22736,22743,22748,22752,22753,22757,22758,22762,22765,22766,22768,22769,22770,22771,22773,22774,22775,22776,22779,22784,22785,22786,22788,22789,22791,22792,22793,22794,22795,22800,22801,22803,22808,22811,22813,22814,22815,22817,22819,22822,22824,22832,22834,22835,22836,22837,22838,22841,22842,22843,22845,22847,22849,22850,22851,22854,22859,22860,22861,22866,22870,22873,22875,22877,22878,22879,22883,22884,22885,22886,22888,22892,22895,22901,22906,22918,22919,22920,22921,22923,22924,22929,22932,22933,22938,22939,22940,22943,22953,22954,22955,22956,22957,22960,22967,22968,22975,22978,22980,22985,22997,22999);
	//23000 - 23500
		code[7] = new Array( 23001,23007,23010,23015,23019,23023,23024,23032,23033,23042,23044,23045,23046,23047,23048,23051,23053,23054,23056,23058,23060,23066,23069,23073,23074,23076,23078,23079,23080,23082,23083,23084,23087,23088,23089,23090,23092,23098,23099,23101,23103,23109,23115,23118,23119,23124,23129,23137,23139,23144,23147,23150,23151,23153,23154,23155,23156,23157,23158,23161,23166,23168,23169,23170,23173,23174,23175,23176,23177,23181,23185,23190,23192,23193,23200,23201,23203,23204,23208,23210,23211,23213,23235,23237,23246,23247,23248,23249,23250,23251,23252,23268,23271,23279,23280,23281,23282,23292,23294,23296,23300,23302,23306,23309,23310,23313,23314,23317,23320,23324,23327,23330,23337,23339,23345,23347,23349,23350,23351,23353,23354,23355,23361,23362,23364,23366,23369,23370,23375,23378,23385,23390,23392,23393,23398,23399,23400,23402,23405,23407,23412,23414,23417,23420,23422,23424,23426,23430,23434,23437,23440,23441,23444,23446,23453,23454,23455,23456,23457,23465,23466,23467,23471,23473,23474,23479,23482,23483,23484,23485,23486,23491,23496,23497);
	//23400 - 24000
		code[8] = new Array( 23503,23509,23511,23514,23515,23516,23517,23533,23539,23540,23543,23545,23547,23548,23549,23550,23551,23552,23554,23557,23558,23571,23572,23575,23576,23577,23579,23580,23581,23582,23584,23585,23587,23590,23591,23593,23595,23597,23598,23599,23602,23604,23605,23606,23613,23618,23619,23625,23626,23634,23635,23639,23642,23643,23646,23647,23649,23654,23659,23664,23666,23669,23670,23671,23672,23677,23679,23680,23681,23682,23683,23684,23685,23687,23694,23702,23703,23704,23705,23706,23707,23708,23710,23730,23732,23737,23738,23739,23740,23741,23742,23743,23744,23745,23746,23747,23748,23749,23757,23761,23765,23772,23773,23776,23777,23778,23779,23780,23781,23782,23783,23785,23787,23791,23794,23795,23797,23802,23804,23806,23810,23811,23812,23813,23816,23817,23818,23824,23827,23829,23832,23836,23841,23850,23851,23852,23853,23855,23867,23870,23876,23878,23880,23885,23887,23891,23892,23894,23895,23896,23898,23899,23900,23901,23903,23904,23905,23908,23910,23914,23917,23918,23920,23923,23924,23925,23926,23928,23931,23939,23941,23947,23948,23950,23951,23952,23953,23958,23960,23963,23971,23972,23973,23974,23979,23987,23990,23993,23995,23998,23999);
	//24000 - 24500
		code[9] = new Array( 24001,24004,24005,24008,24010,24012,24014,24016,24019,24023,24025,24026,24027,24028,24035,24036,24041,24042,24044,24045,24047,24053,24054,24056,24058,24059,24060,24064,24065,24069,24071,24072,24073,24075,24077,24079,24080,24082,24083,24092,24094,24102,24103,24106,24108,24110,24111,24112,24113,24114,24117,24121,24122,24123,24124,24127,24130,24134,24135,24136,24137,24144,24145,24146,24150,24154,24158,24164,24165,24177,24183,24186,24191,24193,24195,24197,24198,24206,24208,24209,24210,24211,24212,24216,24217,24221,24222,24223,24225,24233,24239,24250,24251,24252,24253,24255,24256,24259,24269,24271,24272,24292,24298,24299,24301,24304,24308,24309,24312,24313,24315,24316,24317,24320,24323,24326,24329,24332,24333,24334,24336,24337,24342,24345,24348,24350,24352,24353,24357,24362,24363,24364,24367,24370,24372,24377,24378,24379,24381,24382,24383,24385,24386,24389,24391,24397,24400,24401,24402,24403,24405,24410,24411,24412,24414,24415,24416,24417,24419,24422,24424,24430,24434,24437,24442,24443,24451,24452,24461,24462,24463,24467,24468,24469,24474,24477,24482,24483,24484,24487,24496,24497,24499,24500);
	//24500 - 25000
		code[10] = new Array( 24504,24506,24514,24516,24518,24519,24520,24522,24523,24526,24531,24538,24539,24540,24543,24546,24550,24551,24553,24556,24560,24562,24566,24569,24572,24574,24577,24578,24579,24580,24581,24582,24583,24584,24600,24607,24611,24624,24625,24630,24632,24634,24635,24636,24637,24638,24639,24648,24650,24651,24654,24655,24657,24662,24663,24668,24672,24673,24689,24691,24692,24693,24694,24695,24696,24697,24698,24699,24700,24701,24702,24706,24715,24719,24721,24723,24728,24729,24734,24737,24740,24741,24742,24743,24745,24746,24747,24748,24749,24750,24751,24755,24770,24784,24786,24790,24791,24798,24803,24805,24807,24808,24809,24810,24811,24812,24813,24814,24815,24829,24834,24839,24844,24849,24855,24857,24862,24864,24865,24866,24868,24869,24870,24874,24877,24880,24881,24883,24885,24888,24889,24890,24892,24893,24898,24899,24912,24913,24919,24921,24924,24928,24932,24937,24941,24943,24952,24955,24957,24959,24961,24964,24965,24966,24967,24968,24975,24981,24983,24984,24985,24988,24990,24992,24995,24997,24998);
	//25000 - 25500
		code[11] = new Array( 25015,25017,25019,25021,25024,25028,25038,25039,25040,25041,25042,25043,25044,25045,25047,25049,25050,25051,25052,25053,25057,25058,25068,25071,25075,25076,25090,25093,25094,25099,25103,25107,25111,25112,25116,25117,25118,25126,25128,25132,25135,25137,25141,25143,25144,25145,25147,25148,25156,25157,25164,25167,25173,25174,25175,25181,25183,25191,25192,25193,25194,25195,25196,25205,25208,25218,25221,25227,25229,25232,25241,25242,25243,25244,25245,25246,25247,25248,25249,25250,25251,25252,25253,25254,25255,25266,25271,25274,25280,25281,25283,25285,25301,25309,25310,25311,25312,25313,25314,25315,25316,25317,25318,25319,25320,25321,25322,25348,25349,25350,25354,25362,25367,25368,25369,25370,25371,25372,25373,25374,25375,25376,25377,25378,25379,25380,25381,25382,25383,25390,25392,25393,25397,25399,25407,25426,25427,25435,25436,25437,25438,25439,25440,25441,25442,25443,25444,25446,25450,25452,25459,25460,25465,25470,25471,25478,25483,25491,25493,25498);
	//25500 - 26000
		code[12] = new Array( 25510,25522,25523,25524,25525,25526,25527,25528,25529,25530,25531,25532,25535,25537,25553,25556,25566,25570,25574,25580,25591,25592,25594,25595,25596,25597,25598,25599,25600,25601,25602,25603,25604,25605,25607,25608,25617,25625,25629,25641,25649,25650,25656,25658,25659,25660,25666,25668,25669,25670,25671,25672,25673,25674,25676,25679,25685,25686,25687,25690,25698,25699,25700,25706,25713,25724,25726,25728,25729,25731,25732,25734,25741,25742,25745,25748,25755,25761,25767,25768,25770,25775,25780,25781,25782,25783,25784,25785,25786,25792,25798,25800,25804,25809,25811,25813,25820,25821,25822,25823,25825,25829,25831,25834,25838,25845,25846,25849,25858,25861,25864,25866,25867,25873,25874,25882,25886,25887,25895,25896,25904,25905,25908,25909,25914,25916,25920,25922,25924,25927,25931,25932,25933,25934,25936,25938,25946,25947,25951,25952,25953,25961,25963,25965,25966,25968,25969,25981,25982,25989,25990,25992,25993,25994,25995,25997,25998,25999);
	//26000 - 26500
		code[13] = new Array( 26003,26008,26010,26019,26022,26025,26029,26033,26036,26037,26042,26046,26048,26055,26056,26057,26058,26065,26068,26069,26072,26073,26076,26080,26083,26084,26087,26090,26091,26102,26103,26104,26105,26110,26111,26113,26134,26135,26136,26137,26138,26139,26142,26147,26153,26154,26156,26160,26167,26168,26171,26172,26173,26174,26175,26176,26180,26182,26184,26187,26189,26190,26192,26195,26196,26197,26198,26199,26200,26208,26211,26215,26217,26219,26221,26227,26229,26237,26239,26241,26242,26243,26245,26254,26255,26258,26259,26266,26267,26268,26270,26275,26276,26277,26278,26279,26284,26285,26291,26294,26300,26303,26305,26306,26307,26309,26317,26318,26320,26321,26323,26324,26325,26327,26335,26337,26338,26341,26343,26346,26351,26353,26357,26362,26363,26365,26370,26374,26375,26380,26382,26385,26390,26393,26394,26396,26398,26404,26405,26409,26415,26416,26418,26422,26423,26432,26433,26434,26435,26436,26442,26450,26452,26456,26459,26465,26466,26467,26468,26469,26470,26471,26472,26473,26475,26478,26496,26498);
	//26500 - 27000
		code[14] = new Array( 26504,26506,26511,26518,26523,26526,26528,26529,26530,26531,26532,26533,26534,26535,26536,26537,26538,26539,26540,26541,26545,26556,26557,26558,26559,26567,26581,26582,26583,26592,26593,26600,26617,26619,26621,26622,26624,26625,26626,26627,26628,26629,26630,26631,26632,26633,26634,26635,26636,26637,26638,26639,26640,26641,26645,26649,26651,26654,26658,26659,26660,26663,26668,26672,26678,26679,26686,26687,26695,26698,26706,26709,26710,26711,26712,26713,26714,26715,26716,26717,26718,26719,26720,26721,26722,26723,26724,26725,26726,26727,26728,26729,26730,26732,26736,26739,26746,26756,26760,26765,26766,26773,26776,26777,26778,26782,26789,26790,26806,26807,26808,26809,26810,26811,26812,26813,26814,26815,26816,26817,26818,26819,26821,26826,26831,26841,26843,26850,26853,26861,26878,26879,26880,26881,26882,26883,26889,26902,26904,26905,26906,26907,26908,26909,26910,26911,26912,26913,26914,26915,26916,26918,26919,26920,26921,26923,26924,26925,26926,26929,26934,26938,26942,26947,26950,26951,26957,26960,26965,26977,26980,26983,26994,26995);
	//27000 - 27500
		code[15] = new Array( 27004,27005,27006,27007,27008,27009,27012,27013,27015,27016,27017,27018,27019,27020,27023,27026,27032,27037,27039,27042,27058,27064,27066,27072,27077,27079,27080,27089,27090,27093,27094,27095,27096,27098,27099,27100,27101,27102,27103,27104,27105,27107,27113,27114,27119,27120,27125,27129,27130,27139,27147,27148,27150,27152,27154,27162,27164,27170,27172,27177,27178,27179,27180,27181,27182,27183,27184,27185,27187,27190,27191,27202,27203,27205,27210,27212,27218,27219,27223,27228,27235,27237,27244,27246,27248,27249,27250,27251,27252,27253,27255,27256,27257,27258,27259,27260,27261,27266,27270,27272,27274,27275,27279,27288,27289,27293,27303,27305,27306,27307,27312,27313,27314,27317,27324,27326,27327,27328,27329,27332,27336,27337,27338,27342,27346,27348,27349,27350,27351,27352,27362,27363,27364,27366,27369,27373,27378,27380,27381,27382,27383,27389,27390,27391,27393,27397,27398,27399,27404,27405,27406,27412,27413,27419,27420,27421,27423,27426,27428,27430,27431,27433,27434,27435,27438,27440,27445,27456,27460,27471,27474,27475,27479,27480,27482,27485,27496,27497,27499,27500);
	//27500 - 28000
		code[16] = new Array( 27502,27503,27504,27505,27507,27508,27509,27514,27516,27517,27521,27525,27527,27531,27536,27538,27539,27546,27548,27549,27553,27560,27561,27564,27569,27572,27576,27577,27579,27582,27585,27586,27598,27601,27605,27609,27612,27613,27615,27617,27621,27625,27626,27629,27630,27633,27636,27637,27638,27642,27655,27658,27662,27666,27671,27676,27678,27682,27689,27693,27697,27698,27701,27703,27705,27706,27708,27709,27716,27717,27719,27720,27721,27729,27731,27734,27736,27738,27746,27747,27748,27756,27758,27765,27767,27769,27772,27775,27793,27799,27806,27807,27808,27809,27810,27811,27812,27813,27814,27815,27816,27817,27818,27823,27826,27829,27848,27851,27854,27864,27871,27876,27878,27882,27892,27894,27895,27896,27898,27899,27900,27901,27902,27903,27906,27909,27910,27923,27924,27925,27932,27937,27939,27940,27942,27971,27972,27973,27974,27975,27976,27977,27978,27979,27980,27981,27982,27983,27984,27985,27986,27987,27988,27989,27990,27991,27995,27996,27997);
	//28000 - 28500
		code[17] = new Array( 28011,28017,28018,28019,28033,28047,28054,28057,28058,28059,28060,28061,28062,28063,28064,28065,28066,28067,28068,28069,28070,28071,28072,28073,28077,28080,28081,28086,28089,28097,28099,28110,28135,28152,28158,28159,28161,28162,28164,28166,28167,28168,28169,28170,28171,28172,28173,28174,28175,28176,28177,28178,28179,28180,28181,28182,28183,28184,28190,28201,28202,28215,28226,28232,28236,28239,28240,28247,28249,28266,28268,28269,28272,28277,28278,28282,28283,28284,28285,28286,28287,28288,28289,28290,28291,28292,28293,28294,28295,28298,28299,28300,28305,28309,28314,28328,28329,28332,28333,28341,28344,28347,28375,28377,28378,28379,28381,28382,28383,28384,28385,28386,28387,28388,28389,28390,28391,28392,28393,28394,28400,28403,28410,28420,28427,28428,28432,28433,28438,28439,28443,28445,28452,28456,28468,28477,28482,28484,28485,28486,28487,28488,28489,28490,28491,28492,28493);
	//28500 - 29000
		code[18] = new Array( 28502,28505,28508,28517,28520,28529,28532,28533,28537,28545,28547,28554,28559,28561,28568,28569,28570,28571,28572,28573,28575,28597,28599,28603,28606,28613,28624,28625,28626,28627,28630,28631,28633,28634,28645,28650,28659,28661,28662,28664,28665,28669,28674,28675,28680,28688,28690,28691,28702,28709,28716,28717,28718,28726,28733,28743,28747,28749,28750,28751,28752,28755,28756,28761,28764,28775,28780,28781,28782,28783,28786,28787,28789,28791,28793,28795,28798,28799,28800,28801,28807,28808,28809,28811,28812,28813,28815,28816,28823,28827,28828,28829,28830,28832,28834,28835,28837,28838,28839,28840,28842,28850,28854,28857,28859,28860,28861,28863,28864,28865,28866,28867,28868,28873,28876,28880,28885,28886,28891,28895,28899,28901,28902,28903,28904,28905,28906,28907,28908,28909,28910,28913,28914,28917,28926,28929,28931,28933,28935,28936,28943,28945,28946,28948,28949,28950,28952,28957,28964,28967,28969,28970,28971,28972,28973,28979,28980,28981,28983,28984,28985,28987,28988,28989,28990,28991,28992,28997,29000);
	//29000 - 29500
		code[19] = new Array( 29002,29007,29009,29013,29015,29019,29035,29037,29039,29041,29043,29044,29045,29046,29047,29049,29050,29052,29054,29055,29059,29064,29067,29068,29069,29070,29073,29075,29077,29078,29080,29090,29091,29094,29099,29101,29102,29108,29110,29111,29114,29115,29132,29133,29137,29139,29143,29149,29150,29155,29161,29162,29163,29167,29171,29173,29174,29175,29178,29184,29188,29192,29193,29195,29198,29199,29201,29202,29205,29206,29207,29208,29212,29216,29217,29220,29221,29227,29230,29231,29233,29234,29235,29236,29239,29244,29248,29251,29253,29261,29262,29264,29265,29268,29269,29271,29276,29284,29285,29286,29288,29291,29293,29297,29301,29306,29314,29315,29319,29322,29327,29332,29337,29340,29343,29344,29355,29357,29361,29362,29363,29366,29367,29368,29369,29371,29372,29374,29383,29384,29389,29391,29395,29397,29403,29405,29406,29410,29413,29415,29420,29421,29422,29423,29424,29425,29426,29429,29442,29443,29444,29445,29446,29449,29453,29454,29456,29460,29461,29466,29471,29472,29473,29476,29480,29482,29483,29484,29486,29487,29496,29497);
	//29500 - 30000
		code[20] = new Array( 29501,29505,29510,29511,29512,29515,29519,29523,29524,29525,29526,29532,29539,29540,29549,29553,29556,29561,29580,29581,29583,29584,29585,29592,29593,29594,29595,29596,29598,29603,29607,29610,29614,29615,29616,29617,29626,29629,29633,29636,29641,29646,29647,29648,29649,29653,29663,29665,29666,29668,29670,29676,29679,29680,29681,29682,29683,29687,29689,29691,29698,29710,29711,29712,29713,29714,29715,29716,29717,29719,29720,29721,29724,29726,29727,29735,29751,29752,29753,29755,29756,29757,29758,29763,29765,29767,29768,29769,29772,29779,29782,29784,29789,29792,29793,29797,29798,29800,29803,29804,29812,29814,29815,29816,29818,29819,29826,29828,29836,29837,29838,29839,29841,29843,29846,29849,29851,29853,29858,29860,29868,29870,29875,29876,29881,29884,29892,29894,29895,29896,29897,29900,29901,29902,29904,29905,29906,29907,29927,29930,29931,29933,29935,29936,29937,29938,29939,29944,29945,29946,29948,29953,29957,29958,29961,29962,29966,29977,29979,29982,29984,29987,29988,29991);
	//30000 - 30500
		code[21] = new Array( 30004,30005,30006,30011,30012,30017,30018,30019,30020,30021,30022,30025,30026,30029,30032,30033,30034,30035,30037,30038,30039,30040,30046,30048,30049,30055,30056,30057,30061,30062,30065,30066,30067,30068,30069,30074,30075,30076,30081,30082,30083,30085,30088,30089,30093,30094,30098,30099,30102,30103,30107,30108,30110,30111,30112,30113,30118,30120,30121,30124,30125,30126,30127,30129,30132,30135,30147,30150,30152,30153,30163,30166,30172,30181,30184,30185,30186,30187,30188,30190,30210,30212,30213,30214,30215,30222,30226,30231,30232,30250,30251,30252,30254,30262,30263,30265,30267,30270,30271,30272,30273,30276,30277,30282,30283,30285,30286,30287,30289,30292,30293,30299,30301,30302,30307,30310,30311,30312,30315,30319,30323,30324,30326,30327,30330,30336,30339,30341,30348,30349,30352,30353,30356,30359,30360,30367,30368,30369,30370,30371,30373,30375,30376,30377,30380,30385,30386,30387,30390,30391,30393,30396,30400,30401,30407,30411,30412,30415,30416,30417,30421,30422,30423,30424,30425,30432,30434,30440,30443,30454,30461,30463,30464,30466,30470,30476,30477,30478,30479,30484,30486,30487,30488,30492,30494,30497,30500);
	//30500 - 31000
		code[22] = new Array( 30502,30506,30507,30508,30510,30512,30527,30528,30529,30530,30531,30536,30537,30544,30545,30547,30551,30552,30557,30564,30576,30577,30578,30579,30580,30581,30582,30583,30584,30586,30587,30598,30602,30608,30610,30611,30612,30614,30616,30628,30630,30633,30638,30639,30648,30649,30654,30656,30657,30659,30661,30662,30664,30667,30673,30674,30678,30685,30687,30689,30692,30694,30698,30699,30708,30709,30710,30718,30719,30720,30721,30724,30727,30728,30730,30731,30741,30742,30743,30744,30745,30746,30747,30748,30750,30756,30774,30777,30778,30779,30780,30781,30782,30783,30784,30785,30786,30788,30790,30791,30795,30799,30801,30803,30804,30805,30806,30807,30808,30809,30810,30811,30815,30817,30819,30822,30823,30834,30835,30836,30837,30838,30839,30840,30842,30845,30850,30856,30858,30859,30861,30864,30866,30875,30876,30877,30886,30894,30895,30897,30901,30902,30903,30904,30905,30909,30911,30912,30914,30918,30919,30930,30931,30934,30935,30936,30937,30940,30948,30950,30955,30958,30960,30961,30965,30966,30968,30976,30979,30982,30983,30984,30986,30987,30989,30991,30997,30998,31000);
	//31000 - 31500
		code[23] = new Array( 31002,31007,31008,31010,31022,31024,31026,31027,31028,31030,31031,31035,31036,31043,31053,31054,31064,31065,31074,31078,31084,31086,31087,31089,31093,31094,31095,31096,31099,31102,31104,31107,31108,31109,31110,31111,31113,31116,31121,31129,31133,31134,31135,31139,31141,31145,31151,31157,31164,31170,31171,31172,31174,31175,31178,31180,31184,31187,31188,31191,31193,31194,31195,31201,31202,31205,31208,31215,31216,31217,31218,31219,31220,31221,31225,31228,31229,31230,31231,31233,31238,31239,31241,31246,31247,31254,31261,31265,31267,31268,31269,31271,31273,31274,31276,31277,31282,31283,31284,31285,31286,31288,31290,31294,31297,31298,31299,31301,31305,31311,31312,31313,31314,31315,31317,31321,31325,31326,31331,31332,31333,31334,31338,31343,31346,31347,31351,31356,31357,31362,31363,31373,31374,31377,31379,31386,31387,31388,31389,31393,31396,31397,31398,31399,31405,31408,31417,31419,31420,31421,31426,31427,31430,31432,31433,31436,31437,31438,31439,31440,31442,31443,31444,31445,31446,31447,31450,31451,31452,31453,31454,31457,31458,31463,31464,31465,31466,31468,31472,31473,31474,31475,31476,31477,31480,31484,31486,31490,31491,31495,31499,31500);
	//31500 - 32000
		code[24] = new Array( 31501,31508,31509,31510,31511,31516,31519,31521,31527,31529,31542,31543,31545,31546,31548,31549,31550,31551,31553,31554,31555,31571,31573,31575,31577,31578,31579,31580,31581,31582,31583,31586,31592,31594,31595,31596,31599,31609,31610,31611,31612,31613,31614,31615,31616,31617,31619,31622,31625,31634,31635,31642,31646,31647,31650,31651,31653,31654,31655,31656,31657,31658,31659,31662,31664,31666,31667,31670,31674,31675,31676,31677,31679,31682,31683,31685,31688,31693,31695,31696,31697,31698,31699,31702,31703,31724,31725,31726,31727,31733,31734,31738,31740,31748,31752,31762,31763,31764,31765,31766,31767,31768,31770,31771,31780,31790,31791,31793,31794,31796,31797,31798,31802,31809,31810,31812,31814,31819,31822,31823,31825,31826,31829,31830,31832,31837,31838,31841,31842,31848,31853,31856,31857,31860,31862,31863,31867,31868,31870,31874,31875,31878,31879,31883,31886,31887,31888,31891,31897,31898,31899,31900,31901,31904,31908,31910,31913,31914,31915,31916,31917,31918,31920,31926,31927,31928,31936,31937,31938,31939,31940,31942,31943,31945,31949,31951,31955,31960,31962,31963,31969,31971,31972,31973,31974,31977,31979,31981,31987,31989,31993,31994,31996,31999);
	//32000 - 32500
		code[25] = new Array( 32035,32036,32037,32038,32039,32042,32045,32052,32055,32072,32073,32075,32076,32077,32087,32089,32090,32093,32096,32100,32101,32108,32116,32117,32118,32119,32120,32126,32130,32135,32137,32138,32139,32144,32149,32151,32152,32153,32154,32155,32164,32165,32168,32171,32179,32182,32195,32200,32205,32207,32208,32209,32211,32212,32213,32214,32220,32226,32228,32229,32235,32237,32245,32248,32252,32253,32254,32255,32256,32257,32258,32260,32261,32262,32263,32280,32281,32294,32295,32296,32300,32330,32331,32333,32334,32335,32347,32349,32356,32357,32358,32359,32364,32366,32369,32383,32387,32388,32389,32393,32398,32400,32402,32413,32414,32415,32416,32417,32418,32419,32420,32421,32422,32423,32424,32425,32426,32427,32428,32429,32430,32431,32432,32433,32434,32435,32436,32437,32438,32439,32440,32441,32442,32443,32444,32445,32446,32447,32448,32449,32450,32451,32452,32453,32454,32455,32456,32457,32458,32459,32460,32461,32462,32463,32464,32465,32466,32467,32468,32469,32470,32471,32472,32473,32474,32475,32476,32477,32478,32479,32480,32481,32482,32483,32484,32485,32486,32487,32488,32489,32490,32491,32492,32493,32494,32495,32496,32497,32498,32499,32500);
	//32500 - 33000
		code[26] = new Array( 32501,32502,32503,32504,32505,32506,32507,32508,32509,32510,32511,32512,32513,32514,32515,32516,32517,32518,32519,32520,32521,32522,32523,32524,32525,32526,32527,32528,32529,32530,32531,32532,32533,32534,32535,32536,32537,32538,32539,32540,32541,32542,32543,32544,32545,32546,32547,32548,32549,32550,32551,32552,32553,32554,32555,32556,32557,32558,32559,32560,32561,32562,32563,32564,32565,32567,32571,32572,32576,32577,32578,32582,32583,32585,32590,32594,32595,32598,32599,32601,32602,32610,32612,32623,32625,32628,32632,32640,32641,32642,32644,32655,32656,32659,32663,32664,32665,32671,32675,32682,32683,32686,32692,32708,32710,32712,32723,32726,32728,32729,32730,32733,32740,32743,32758,32762,32770,32776,32777,32778,32787,32794,32797,32800,32802,32803,32805,32807,32811,32813,32814,32815,32817,32818,32824,32826,32827,32828,32832,32833,32834,32836,32837,32841,32843,32844,32845,32846,32851,32852,32853,32855,32857,32859,32863,32864,32865,32866,32867,32869,32870,32872,32873,32874,32875,32877,32878,32884,32890,32891,32892,32896,32897,32899,32904,32909,32910,32913,32916,32919,32926,32927,32928,32932,32934,32935,32936,32940,32944,32947,32950,32951,32953,32955,32956,32957,32958,32959,32960,32961,32966,32971,32978,32979,32991,32994,32999,33000);
	//33000 - 33500
		code[27] = new Array( 33001,33002,33003,33004,33006,33014,33015,33023,33027,33028,33031,33033,33035,33036,33037,33038,33039,33040,33041,33042,33043,33044,33047,33050,33052,33056,33062,33064,33066,33070,33073,33074,33075,33076,33077,33078,33079,33080,33083,33084,33087,33088,33089,33090,33093,33096,33097,33110,33111,33112,33113,33114,33117,33119,33123,33128,33130,33132,33133,33141,33147,33148,33149,33150,33153,33156,33157,33166,33168,33169,33170,33171,33172,33174,33185,33188,33189,33194,33197,33199,33206,33208,33217,33224,33227,33230,33235,33236,33238,33244,33252,33259,33263,33264,33265,33269,33270,33277,33283,33286,33294,33295,33299,33303,33304,33305,33306,33315,33316,33318,33319,33321,33325,33326,33328,33329,33339,33342,33345,33347,33350,33352,33354,33356,33357,33364,33373,33376,33378,33381,33383,33386,33392,33395,33398,33401,33402,33403,33409,33410,33414,33415,33416,33417,33420,33429,33430,33431,33436,33446,33450,33458,33471,33473,33476,33477,33478,33479,33480,33481,33482,33483,33484,33485,33486,33487,33488,33496,33498);
	//33500 - 34000
		code[28] = new Array( 33501,33506,33513,33518,33527,33528,33532,33533,33535,33546,33547,33550,33551,33552,33553,33554,33555,33556,33557,33560,33562,33565,33567,33569,33571,33582,33584,33597,33598,33606,33621,33623,33624,33625,33626,33627,33628,33629,33630,33631,33632,33633,33634,33635,33636,33637,33638,33639,33640,33641,33642,33643,33644,33645,33646,33647,33648,33649,33650,33657,33664,33666,33668,33669,33681,33692,33695,33697,33708,33709,33713,33714,33715,33716,33717,33718,33719,33720,33721,33722,33723,33724,33726,33741,33744,33746,33747,33754,33766,33773,33783,33792,33794,33797,33800,33812,33813,33814,33815,33816,33817,33818,33820,33821,33822,33823,33824,33825,33826,33828,33829,33830,33831,33832,33834,33838,33854,33857,33864,33866,33871,33875,33877,33880,33884,33890,33892,33898,33905,33906,33915,33916,33919,33920,33921,33923,33924,33925,33927,33928,33929,33930,33931,33932,33938,33939,33941,33942,33955,33957,33958,33965,33971,33973,33975,33981,33982,33987,33992);
	//34000 - 34500
		code[29] = new Array( 34005,34008,34009,34010,34012,34013,34014,34015,34016,34017,34018,34019,34020,34021,34022,34029,34037,34040,34049,34051,34052,34053,34064,34075,34082,34098,34099,34100,34101,34102,34103,34104,34105,34106,34108,34111,34114,34123,34124,34127,34128,34130,34138,34140,34143,34159,34160,34162,34163,34164,34173,34175,34194,34195,34199,34213,34219,34220,34221,34222,34226,34235,34236,34241,34250,34252,34259,34260,34262,34267,34272,34279,34286,34291,34292,34293,34300,34306,34307,34312,34317,34318,34319,34320,34322,34323,34324,34325,34326,34333,34344,34347,34351,34352,34359,34365,34369,34370,34372,34373,34377,34378,34383,34385,34391,34392,34394,34397,34400,34406,34412,34418,34421,34422,34424,34429,34430,34431,34432,34433,34434,34435,34436,34440,34441,34447,34450,34459,34463,34464,34470,34475,34476,34477,34478,34482);
	//34500 - 35000
		code[30] = new Array( 34506,34509,34510,34511,34514,34517,34528,34529,34533,34535,34542,34543,34544,34545,34546,34547,34548,34556,34557,34559,34575,34576,34580,34581,34582,34583,34589,34591,34603,34607,34614,34617,34621,34628,34629,34631,34632,34633,34634,34635,34672,34673,34674,34684,34685,34686,34687,34688,34694,34698,34699,34700,34702,34709,34713,34720,34721,34725,34726,34727,34728,34729,34737,34753,34759,34765,34766,34767,34768,34773,34774,34778,34793,34798,34800,34801,34805,34808,34813,34820,34823,34830,34831,34834,34840,34842,34846,34855,34861,34868,34874,34882,34885,34886,34887,34889,34895,34896,34897,34900,34904,34908,34910,34911,34912,34916,34917,34918,34924,34926,34931,34936,34938,34939,34948,34949,34950,34951,34954,34959,34960,34964,34972,34973,34976,34979,34981,34982,34985,34989,34990,34991,34992,34995,34996,34997);
	//35000 - 35500
		code[31] = new Array( 35003,35007,35011,35012,35013,35014,35015,35016,35025,35027,35040,35042,35043,35044,35045,35046,35049,35050,35053,35061,35071,35072,35075,35076,35080,35085,35087,35099,35100,35101,35104,35108,35112,35124,35129,35130,35135,35136,35139,35141,35143,35144,35146,35149,35150,35156,35157,35173,35175,35176,35184,35189,35191,35192,35197,35200,35204,35207,35209,35210,35212,35213,35214,35216,35217,35218,35220,35225,35226,35232,35237,35239,35240,35241,35243,35248,35249,35251,35252,35253,35256,35259,35260,35265,35266,35267,35268,35269,35270,35271,35272,35273,35274,35275,35276,35277,35278,35279,35280,35281,35287,35288,35294,35303,35306,35310,35311,35317,35321,35325,35329,35333,35334,35337,35339,35341,35348,35353,35354,35356,35360,35361,35364,35366,35368,35369,35371,35374,35375,35378,35379,35381,35383,35384,35389,35394,35395,35399,35401,35403,35411,35418,35420,35421,35423,35428,35429,35431,35434,35439,35448,35453,35454,35456,35464,35465,35466,35470,35472,35476,35479,35483,35484,35485,35487,35490,35497,35500);
	//35500 - 36000
		code[32] = new Array( 35501,35502,35503,35505,35507,35508,35509,35511,35521,35530,35532,35534,35536,35546,35555,35557,35561,35562,35564,35577,35581,35587,35593,35596,35615,35617,35625,35629,35634,35636,35640,35647,35651,35652,35660,35661,35675,35678,35681,35682,35684,35689,35694,35697,35698,35699,35701,35702,35708,35713,35715,35719,35721,35725,35727,35728,35729,35735,35739,35741,35744,35745,35746,35747,35748,35749,35750,35751,35752,35753,35754,35755,35756,35757,35758,35759,35760,35761,35762,35763,35764,35765,35766,35767,35768,35769,35770,35771,35772,35773,35774,35775,35776,35777,35778,35779,35780,35781,35782,35783,35784,35785,35786,35787,35788,35789,35790,35791,35792,35793,35794,35795,35796,35797,35798,35799,35800,35801,35802,35803,35804,35805,35806,35807,35808,35809,35810,35811,35812,35813,35814,35815,35816,35817,35818,35819,35820,35821,35822,35823,35824,35825,35826,35827,35828,35829,35830,35831,35832,35833,35834,35835,35836,35837,35838,35839,35840,35841,35842,35843,35844,35845,35846,35847,35848,35849,35850,35851,35852,35853,35854,35855,35856,35857,35858,35859,35860,35861,35862,35863,35864,35865,35866,35867,35868,35869,35870,35871,35872,35873,35874,35875,35876,35877,35878,35879,35880,35881,35882,35883,35884,35885,35886,35887,35888,35889,35890,35891,35892,35893,35894,35896,35898,35904,35908,35921,35922,35923,35928,35929,35931,35934,35936,35939,35943,35950,35956,35964,35966,35967,35971,35975,35976,35979,35982,35990,35995,35999);
	//36000 - 36500
		code[33] = new Array( 36006,36013,36014,36017,36038,36041,36043,36045,36046,36048,36052,36054,36056,36059,36073,36075,36079,36082,36086,36087,36095,36097,36099,36107,36108,36110,36113,36114,36120,36122,36124,36125,36126,36127,36128,36129,36130,36131,36132,36133,36134,36135,36136,36137,36138,36139,36140,36141,36142,36143,36144,36145,36146,36147,36148,36149,36150,36151,36152,36153,36154,36155,36156,36157,36158,36159,36160,36161,36162,36163,36164,36165,36166,36167,36168,36169,36170,36171,36172,36173,36174,36175,36176,36177,36178,36179,36180,36181,36182,36183,36184,36185,36186,36187,36188,36189,36190,36191,36192,36193,36194,36195,36197,36202,36209,36213,36218,36220,36222,36223,36226,36227,36230,36231,36232,36235,36247,36248,36250,36253,36254,36258,36260,36262,36265,36272,36273,36280,36283,36285,36288,36291,36292,36297,36298,36306,36308,36318,36325,36333,36341,36342,36343,36344,36345,36347,36353,36360,36363,36364,36366,36392,36394,36396,36397,36399,36402,36407,36410,36411,36419,36422,36431,36433,36434,36440,36456,36459,36462,36464,36465,36469,36471,36473,36477,36478,36479,36480,36483,36495);
	//36500 - 37000
		code[34] = new Array( 36505,36507,36508,36514,36519,36525,36526,36527,36528,36529,36531,36532,36533,36534,36535,36536,36537,36539,36540,36542,36543,36545,36547,36548,36549,36550,36551,36552,36558,36560,36565,36566,36569,36570,36578,36579,36580,36586,36589,36592,36594,36595,36605,36612,36620,36623,36633,36641,36642,36647,36648,36651,36653,36656,36657,36666,36668,36669,36673,36682,36684,36700,36709,36710,36711,36712,36713,36714,36715,36716,36717,36718,36719,36720,36721,36722,36723,36724,36725,36726,36727,36728,36729,36730,36731,36732,36733,36734,36735,36736,36737,36738,36739,36740,36741,36742,36743,36744,36745,36746,36747,36748,36749,36750,36751,36752,36753,36754,36755,36756,36757,36758,36759,36760,36761,36762,36765,36766,36768,36769,36770,36772,36773,36775,36777,36778,36779,36780,36787,36789,36790,36791,36792,36793,36794,36795,36796,36797,36798,36800,36801,36803,36807,36808,36810,36812,36815,36816,36824,36825,36826,36827,36828,36829,36830,36831,36839,36841,36844,36847,36849,36850,36851,36857,36871,36872,36873,36874,36878,36882,36883,36888,36901,36902,36903,36904,36905,36906,36907,36908,36912,36915,36919,36921,36922,36923,36928,36931,36933,36934,36936,36940,36950,36951,36954,36959,36961,36964,36965,36966,36970,36972,36977);
	//37000 - 37500
		code[35] = new Array( 37001,37004,37006,37010,37011,37014,37018,37020,37021,37028,37032,37033,37035,37036,37037,37038,37047,37049,37050,37051,37052,37056,37058,37060,37062,37065,37068,37069,37071,37072,37073,37074,37075,37086,37094,37095,37102,37110,37111,37112,37130,37132,37139,37141,37157,37175,37180,37181,37186,37201,37204,37209,37211,37212,37213,37214,37222,37223,37227,37229,37232,37233,37238,37243,37244,37245,37246,37247,37256,37260,37262,37268,37269,37270,37271,37272,37284,37286,37289,37302,37304,37307,37311,37316,37320,37322,37330,37334,37339,37342,37343,37344,37345,37349,37359,37360,37362,37366,37370,37371,37372,37374,37384,37387,37390,37395,37400,37403,37405,37407,37408,37409,37410,37416,37417,37418,37419,37420,37423,37429,37435,37436,37441,37442,37443,37444,37447,37461,37464,37465,37468,37469,37471,37474,37480,37481,37482,37483,37486,37489,37491,37492,37493,37495);
	//37500 - 38000
		code[36] = new Array( 37505,37508,37513,37519,37520,37522,37534,37535,37549,37550,37551,37552,37553,37560,37562,37565,37566,37567,37588,37590,37594,37595,37596,37602,37603,37605,37611,37612,37613,37618,37619,37620,37621,37622,37629,37635,37637,37639,37642,37649,37655,37660,37676,37680,37681,37682,37687,37690,37691,37693,37694,37695,37696,37697,37698,37699,37700,37701,37704,37715,37725,37727,37730,37734,37736,37737,37739,37742,37743,37746,37747,37748,37752,37757,37759,37761,37764,37765,37766,37767,37771,37776,37779,37788,37792,37803,37805,37814,37816,37817,37818,37819,37820,37821,37822,37823,37825,37829,37830,37833,37835,37843,37851,37856,37861,37865,37866,37867,37869,37871,37872,37873,37874,37875,37876,37889,37890,37892,37893,37896,37911,37914,37915,37916,37917,37918,37919,37921,37922,37923,37924,37925,37926,37927,37933,37935,37940,37950,37953,37954,37955,37965,37966,37971,37972,37974,37976,37977,37978,37979,37980,37983,37985,37989,37990,37991,37996);
	//38000 - 38500
		code[37] = new Array( 38009,38010,38011,38020,38021,38022,38023,38024,38025,38026,38027,38028,38029,38030,38031,38032,38033,38034,38035,38036,38037,38038,38039,38040,38041,38042,38043,38044,38045,38046,38047,38048,38049,38050,38051,38052,38053,38054,38055,38056,38057,38058,38059,38060,38061,38062,38063,38064,38065,38066,38067,38068,38069,38070,38071,38072,38073,38074,38075,38076,38077,38078,38079,38080,38081,38082,38083,38084,38085,38086,38087,38088,38089,38090,38091,38092,38093,38094,38095,38096,38097,38098,38099,38100,38101,38102,38103,38104,38105,38106,38107,38108,38109,38110,38111,38112,38113,38114,38115,38116,38117,38118,38119,38120,38121,38122,38123,38124,38125,38126,38127,38128,38129,38130,38131,38132,38133,38134,38135,38136,38137,38138,38139,38140,38141,38142,38143,38144,38145,38146,38147,38148,38149,38150,38151,38152,38153,38154,38155,38156,38157,38158,38159,38160,38161,38162,38163,38164,38165,38166,38167,38168,38169,38170,38171,38172,38173,38174,38175,38176,38177,38178,38179,38180,38181,38182,38183,38184,38185,38186,38187,38188,38189,38190,38191,38192,38193,38194,38195,38196,38197,38198,38199,38200,38201,38202,38203,38204,38205,38206,38207,38208,38209,38210,38211,38212,38213,38214,38215,38216,38217,38218,38219,38220,38221,38222,38223,38224,38225,38226,38227,38228,38229,38230,38231,38232,38233,38234,38235,38236,38237,38238,38239,38240,38241,38242,38243,38244,38245,38246,38247,38248,38249,38250,38251,38252,38253,38254,38255,38256,38257,38258,38259,38260,38261,38262,38264,38265,38270,38271,38273,38276,38277,38279,38282,38293,38294,38295,38297,38298,38301,38304,38306,38310,38311,38314,38319,38322,38323,38324,38328,38337,38338,38340,38350,38351,38359,38360,38361,38365,38374,38375,38376,38377,38378,38379,38380,38381,38382,38383,38384,38385,38386,38387,38388,38389,38390,38391,38392,38393,38394,38395,38396,38397,38398,38399,38400,38401,38402,38403,38404,38405,38406,38407,38408,38409,38410,38411,38412,38413,38414,38415,38416,38417,38418,38419,38420,38421,38422,38423,38424,38425,38426,38427,38429,38431,38437,38438,38439,38441,38443,38451,38452,38453,38454,38455,38456,38462,38465,38469,38470,38471,38472,38473,38482,38485,38486,38487,38489,38490,38496);
	//38500 - 39000
		code[38] = new Array( 38501,38502,38503,38504,38505,38510,38521,38522,38523,38527,38529,38530,38540,38543,38544,38550,38554,38557,38559,38560,38563,38565,38566,38571,38573,38575,38578,38581,38582,38583,38586,38589,38590,38607,38608,38609,38624,38628,38630,38631,38635,38636,38637,38638,38643,38644,38652,38654,38657,38659,38666,38668,38676,38677,38679,38682,38683,38689,38701,38705,38707,38708,38710,38711,38715,38716,38720,38721,38725,38730,38732,38733,38734,38735,38736,38737,38739,38740,38741,38743,38745,38749,38751,38755,38756,38757,38759,38763,38765,38767,38769,38773,38777,38790,38791,38793,38796,38800,38801,38802,38803,38805,38806,38811,38815,38823,38825,38831,38832,38833,38834,38836,38837,38840,38842,38844,38845,38846,38848,38850,38856,38858,38865,38866,38874,38875,38880,38882,38884,38886,38887,38888,38889,38890,38891,38892,38894,38895,38898,38900,38901,38903,38908,38921,38923,38932,38933,38937,38938,38943,38946,38947,38949,38954,38956,38958,38961,38963,38964,38966,38970,38972,38973,38974,38975,38976,38978,38983,38987,38996,38997,38998);
	//39000 - 39500
		code[39] = new Array( 39002,39009,39014,39016,39020,39021,39022,39029,39030,39031,39032,39033,39034,39035,39036,39037,39038,39039,39040,39041,39042,39043,39044,39045,39046,39047,39048,39049,39050,39051,39052,39053,39054,39055,39056,39057,39058,39059,39060,39061,39062,39063,39064,39065,39066,39067,39068,39069,39070,39071,39072,39073,39074,39075,39076,39077,39078,39079,39082,39083,39088,39092,39093,39095,39097,39107,39109,39111,39112,39114,39117,39118,39119,39120,39121,39122,39123,39124,39125,39126,39127,39128,39129,39130,39132,39133,39134,39136,39137,39140,39142,39144,39148,39150,39152,39153,39155,39157,39159,39160,39163,39167,39169,39172,39174,39179,39181,39182,39183,39193,39196,39197,39200,39202,39203,39206,39220,39222,39223,39224,39225,39227,39232,39234,39236,39238,39242,39245,39247,39258,39261,39264,39266,39267,39268,39269,39270,39271,39272,39273,39274,39275,39276,39277,39278,39279,39280,39281,39282,39283,39284,39285,39286,39287,39288,39289,39290,39291,39292,39293,39294,39295,39296,39297,39298,39299,39300,39301,39302,39303,39304,39305,39306,39307,39308,39309,39310,39311,39312,39313,39314,39315,39316,39317,39322,39323,39327,39328,39330,39332,39337,39338,39350,39351,39352,39356,39358,39359,39360,39364,39365,39366,39368,39370,39386,39390,39392,39393,39398,39400,39403,39407,39410,39411,39413,39424,39432,39436,39440,39442,39443,39447,39448,39455,39457,39462,39464,39471,39475,39483,39484,39495,39499);
	//39500 - 40000
		code[40] = new Array( 39505,39512,39516,39517,39521,39523,39532,39533,39534,39535,39536,39537,39538,39539,39540,39541,39542,39543,39544,39545,39546,39547,39548,39549,39550,39551,39552,39553,39554,39555,39556,39557,39558,39559,39560,39561,39562,39563,39564,39565,39566,39567,39568,39569,39570,39571,39572,39573,39574,39575,39576,39577,39578,39579,39580,39581,39582,39583,39584,39585,39586,39587,39588,39589,39590,39591,39593,39594,39596,39598,39602,39605,39606,39610,39613,39619,39620,39621,39624,39625,39627,39628,39630,39639,39641,39642,39643,39645,39646,39648,39650,39652,39653,39656,39657,39658,39664,39668,39669,39672,39679,39680,39682,39687,39689,39695,39699,39700,39707,39708,39709,39713,39718,39722,39724,39725,39728,39732,39734,39736,39737,39741,39744,39751,39753,39760,39763,39767,39772,39773,39774,39778,39779,39781,39785,39786,39787,39789,39790,39794,39795,39800,39801,39807,39809,39811,39812,39817,39818,39819,39820,39821,39822,39823,39828,39830,39831,39832,39833,39836,39837,39839,39843,39847,39849,39852,39856,39857,39858,39859,39860,39863,39866,39867,39868,39870,39874,39877,39883,39884,39885,39886,39887,39888,39889,39890,39896,39901,39903,39907,39913,39917,39918,39919,39921,39922,39923,39924,39925,39926,39929,39930,39931,39932,39934,39935,39936,39937,39938,39939,39940,39946,39948,39951,39952,39953,39957,39958,39960,39961,39962,39963,39966,39967,39968,39970,39974,39975,39978,39982,39983,39984,39989,39992,39994);
	//40000 - 40500
		code[41] = new Array( 40002,40003,40005,40007,40015,40017,40019,40026,40027,40028,40029,40033,40036,40037,40041,40042,40043,40044,40047,40048,40050,40054,40059,40060,40061,40062,40063,40064,40065,40066,40067,40068,40069,40070,40071,40072,40073,40074,40075,40076,40077,40078,40079,40080,40081,40082,40083,40084,40085,40086,40087,40088,40089,40090,40091,40092,40093,40094,40095,40096,40097,40098,40099,40100,40101,40102,40103,40104,40105,40106,40107,40108,40109,40110,40111,40112,40113,40114,40115,40116,40117,40118,40119,40120,40121,40122,40123,40124,40125,40126,40127,40128,40129,40130,40131,40132,40133,40134,40135,40136,40137,40138,40139,40140,40141,40142,40143,40144,40145,40146,40147,40148,40149,40150,40151,40152,40153,40154,40155,40156,40157,40158,40159,40160,40161,40162,40163,40164,40168,40171,40172,40174,40175,40176,40184,40190,40193,40194,40202,40203,40204,40205,40206,40207,40209,40211,40214,40218,40220,40225,40228,40231,40234,40235,40236,40242,40244,40245,40249,40250,40252,40260,40262,40263,40264,40265,40269,40270,40272,40277,40286,40290,40291,40292,40293,40294,40301,40302,40310,40314,40316,40318,40323,40333,40334,40335,40337,40339,40341,40357,40363,40366,40368,40381,40384,40388,40390,40393,40404,40416,40423,40426,40433,40444,40456,40458,40460,40462,40470,40472,40476,40479,40480,40481,40482,40483,40484,40485,40486,40487,40488,40489,40490,40491,40492,40493,40494,40495,40496,40497,40498,40499,40500);
	//40500 - 41000
		code[42] = new Array( 40501,40502,40503,40504,40505,40506,40507,40508,40509,40510,40511,40512,40513,40514,40515,40516,40517,40518,40519,40520,40521,40522,40523,40524,40525,40526,40527,40528,40529,40530,40531,40532,40533,40534,40535,40536,40537,40538,40539,40540,40541,40542,40543,40544,40545,40546,40547,40548,40549,40550,40551,40552,40553,40554,40555,40556,40557,40558,40559,40560,40561,40562,40563,40564,40566,40567,40568,40571,40574,40577,40580,40581,40591,40592,40597,40598,40600,40606,40610,40611,40614,40616,40618,40619,40620,40623,40625,40626,40627,40632,40633,40634,40637,40639,40641,40644,40645,40646,40647,40649,40650,40651,40658,40663,40665,40673,40674,40675,40681,40682,40684,40689,40696,40702,40706,40707,40708,40709,40712,40715,40716,40717,40721,40724,40727,40733,40735,40737,40742,40743,40761,40762,40764,40767,40772,40773,40784,40785,40787,40794,40802,40808,40809,40813,40819,40828,40829,40831,40832,40833,40834,40835,40836,40837,40838,40839,40840,40841,40842,40843,40844,40846,40847,40851,40854,40855,40857,40858,40859,40861,40862,40863,40865,40867,40869);
	//********************************************************************************
	}
	var isOK = true;			//output 結果
	var count = 0;				//包含的難字數目
	var hw = new Array();		//儲存難字的陣列

	//開始逐字檢核輸入的字串
	str = str.replace("　","");
	for (var i=0; i<str.length; i++){
		var wordInt = str.charCodeAt(i);	//第i個字的int碼
		if (wordInt>19967 && wordInt<40870){
			//2006-04-18 laycf ：fix index設為var以免影響外部變數
			var index = Math.floor((wordInt-19501)/500);
			for (j=0; j<code[index].length; j++){
				if (wordInt==code[index][j]) {
					isOK = false;
					hw[count] = str.charAt(i);
					count++;
					break;
				}
			}
		}

		if (wordInt == 63937){
			isOK = false;
			if(isAlert !== false){
				alert("「" + str.charAt(i) + "」不是系統可辨識的中文字!!\n");
			}
			return isOK;
		}

	}
	if (!isOK){
		var strHw = hw[0];
		for (l=1; l<hw.length; l++){
			strHw = strHw + ", " + hw[l];
		}
		if(isAlert !== false){
			alert("「" + strHw + "」不是系統可辨識的中文字!!\n");
		}
	}
	return isOK;
}

/**
 * 功能說明 : 電話號碼規則檢查。  <br>
 * 規則提供：行政管理部審企科
 * 02	台北市	10碼
 * 02	台北縣	10碼
 * 02	基隆市	10碼
 * 03	桃園縣	9碼
 * 03	新竹市	9碼
 * 03	新竹縣	9碼
 * 03	宜蘭縣	9碼
 * 03	花蓮縣	9碼
 * 037	苗栗縣	9碼
 * 04	苗栗縣卓蘭鎮	10碼
 * 04	台中市	10碼
 * 04	台中縣	10碼
 * 04	彰化縣	9碼
 * 049	南投縣	10碼
 * 049	彰化縣芬園鄉	10碼
 * 05	雲林縣	9碼
 * 05	嘉義市	9碼
 * 05	嘉義縣	9碼
 * 06	台南市	9碼
 * 06	台南縣	9碼
 * 06	澎湖縣	9碼
 * 07	高雄縣	9碼
 * 07	高雄市	9碼
 * 08	屏東縣	9碼
 * 089	台東縣	9碼
 * 0823	金門	9碼
 * 0826	烏坵	9碼
 * 0827	東沙、南沙	9碼
 * 0836	馬祖	9碼
 * 09	手機	10碼 <950303平測討論會，手機要放在一般電話中，方式為09-12345678
 * 處理方式
 * 1.if 區碼.length=0 alert msg 請輸入區碼
 * 2.if 區碼=02,049... (區碼+電話號碼).length!=10 alert 電話號碼長度(含區碼)請輸入10碼
 *    else if 區碼=03,037  (區碼+電話號碼).length!=9  alert 電話號碼長度(含區碼)請輸入9碼
 * 		else if 區碼=04 (區碼+電話號碼).length!=9 &  (區碼+電話號碼).length!=10  alert 電話號碼長度(含區碼)請輸入9或10碼
 *   else alert 請輸入正確區碼及電話號碼
 * 變數說明
 * area區碼 no電話號碼
 **/

function isPhoneNo(area,no)
{
	if (area == null || area=="" ) return false;
	if (no == null || no=="" ) return false;
	phone = area + no;

	if ((area=="02" || area=="049" || area=="09") && phone.length == 10){
		return true;}
	else if ((area=="03" || area=="037" || area=="05" || area=="06" || area=="07" || area=="08" || area=="082" || area=="089" || area=="0823" || area=="0826" || area=="0827" || area=="0836" ) &&  phone.length == 9){
		return true;}
	else if ((area=="04") && (phone.length==9 || phone.length==10)){
		return true;}
	else{
		return false;
	}
}

//檢核 email address
function checkMail(x)
{
	var filter  = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	if (filter.test(x)) return true;
	return false;
}

//檢核 西元年 YYYY-MM-DD
function checkYMD(theDate){
	var reg = /^\d{4}-((0{0,1}[1-9]{1})|(1[0-2]{1}))-((0{0,1}[1-9]{1})|([1-2]{1}[0-9]{1})|(3[0-1]{1}))$/;
	var result=true;
	if(!reg.test(theDate))
		result = false;
	else{
		var arr_hd=theDate.split("-");
		var dateTmp;
		dateTmp= new Date(arr_hd[0],parseFloat(arr_hd[1])-1,parseFloat(arr_hd[2]));
		if(dateTmp.getFullYear()!=parseFloat(arr_hd[0])
			|| dateTmp.getMonth()!=parseFloat(arr_hd[1]) -1
			|| dateTmp.getDate()!=parseFloat(arr_hd[2])){
			result = false
		}
	}
  return result;
}

/**
 *	功能說明：檢核是否為數值及是否符合所指定之整數位及小數位
 *	使用說明：
 *		第一個參數：檢核之傳入數值
 *		第二個參數：整數之位數（若傳入為0時，則整數位只能輸入0）
 *		第三個參數：小數之位數（若傳入為0時，則不可輸入小數位）
 */
function checkNumeralFormat(value, integerNum, decimalNum){

	if(isNaN(value)){
		return false;
	}

	var pointIndex = value.indexOf('.');

	if(pointIndex>=0){
		var decimalValue = value.substring(pointIndex+1);
		if(decimalValue.length>decimalNum){
			return false;
		}
	}

	var integerValue;
	if(pointIndex>=0){
		integerValue = value.substring(0,pointIndex);
	}else{
		integerValue = value;
	}

	if(integerNum==0){
		if(integerValue>0){
			return false;
		}
	}else if(integerValue.length>integerNum){
		return false;
	}

	return true;
}

/**
 *	功能說明：僅能鍵入數字
 *	使用說明：
 *		利用onkeypress使用該function
 */
function numberOnly(){
	return ( event.keyCode > 47 && event.keyCode < 58 );
}

/**
 *	功能說明：僅能鍵入數字及小數點
 *	使用說明：
 *		利用onkeypress使用該function
 */
function numberDotOnly(){
	return ( numberOnly() || event.keyCode==46 );
}

/**
 *	功能說明：僅能鍵入數字及「-」
 *	使用說明：
 *		利用onkeypress使用該function
 */
function dateOnly(){
	return (numberOnly() || event.keyCode==45);
}

/**
 *	功能說明：當參數為null或空字串時，則回傳指定之參數，預設為「--」
 *	使用說明：
 *		第一個參數：參數
 *		第二個參數：取代文字，若不傳入預設為「--」
 */
function nullToChangeValue(v,changeValue){
	if( v && v!=''){
		return v;
	}
	if(changeValue || changeValue==''){
		return changeValue;
	}
	return '--';
}

/**
 *	功能說明：增加訊息
 *	使用說明：
 *		第一個參數：欲接續的訊息內容
 *		第二個參數：欄位名稱
 *		第三個參數：訊息內容
 */
function addMsg(msg,n,memo){
	if(msg!=''){
		msg += '\n';
	}
	msg += n +' [ '+memo+' ] ';
	return msg;
}

/**
 *	功能說明：檢核日期區間
 *	使用說明：
 *		第一個參數：起始日期物件
 *		第二個參數：起始日期欄位名稱
 *		第三個參數：終止日期物件
 *		第四個參數：終止日期欄位名稱
 *		第五個參數：是否為必要輸入欄位
 *		第六個參數：欲接續的訊息內容
 */
function checkDateArea(strDateObj,strDateName,endDateObj,endDateName,isNeedInput,msg){

	var rightColor = '#FFFFFF';
	var errColor = '#FF8888';
	var checkSuccessByStrDate = true;
	var checkSuccessByEndDate = true;
	var strDate = strDateObj.value;
	var endDate = endDateObj.value;

	if(!msg){
		msg = '';
	}

	if(strDate==''){
		checkSuccessByStrDate = false;
		if(isNeedInput){
			msg = addMsg(msg,strDateName,'請輸入日期');
			strDateObj.style.backgroundColor=errColor;
		}else{
			strDateObj.style.backgroundColor=rightColor;
		}

	}else if(!isDate(strDate)){
		msg = addMsg(msg,strDateName,'請輸入正確之日期格式');
		checkSuccessByStrDate = false;
		strDateObj.style.backgroundColor=errColor;
	}else{
		strDateObj.style.backgroundColor=rightColor;
	}

	if(endDate==''){
		checkSuccessByEndDate = false;
		if(isNeedInput){
			msg = addMsg(msg,endDateName,'請輸入日期');
			endDateObj.style.backgroundColor=errColor;
		}else{
			endDateObj.style.backgroundColor=rightColor;
		}
	}else if(!isDate(endDate)){
		msg = addMsg(msg,endDateName,'請輸入正確之日期格式');
		checkSuccessByEndDate = false;
		endDateObj.style.backgroundColor=errColor;
	}else{
		endDateObj.style.backgroundColor=rightColor;
	}

	if(checkSuccessByStrDate && checkSuccessByEndDate){
		if(diffDay(strDate, endDate)<0){
			msg = addMsg(msg,endDateName,endDateName+'不可小於'+strDateName);
			strDateObj.style.backgroundColor=errColor;
			endDateObj.style.backgroundColor=errColor;
		}
	}else if(checkSuccessByStrDate && endDate==''){
		msg = addMsg(msg,endDateName,'當有輸入'+strDateName+'時，則'+endDateName+'需輸入');
		endDateObj.style.backgroundColor=errColor;
	}else if(checkSuccessByEndDate && strDate==''){
		msg = addMsg(msg,strDateName,'當有輸入'+endDateName+'時，則'+strDateName+'需輸入');
		strDateObj.style.backgroundColor=errColor;
	}
	return msg;
}