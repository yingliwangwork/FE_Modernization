/**
 *  @public
 *	@class 協助開發人員於JavaScript進行各種數值運算或轉換數字格式
 *	       (有些方法因運算精確度，可能會有明顯誤差產生)	
 *	@author 
 *	@version 1.00
 **/ 
MathExt = new function(){

	var _roundMode_ROUND_UP = 0;
	var _roundMode_ROUND_DOWN = 1;
	var _roundMode_ROUND_HALF_UP = 2;

	function handleRound(number, size, roundMode){
		if (isNaN(number)) {
			return 0;
		}
		if (isNaN(size)) {
			size = 0;
		}
		var typeIsString = typeof(number)==='string';
		var str;
		if(typeIsString){
			str = number;
		}else{
			str = number.toString();
		}
		var dotIndex = str.indexOf('.');
		if(dotIndex<=0){
			if(typeIsString){
				return parseFloat(number);
			}
			return number;
		}

		var decimalStr = str.substring(dotIndex+1, str.length);
		if(decimalStr.length<=size){
			if(typeIsString){
				return parseFloat(number);
			}
			return number;
		}

		var integerStr = str.substring(0, dotIndex);
		var outputDecimal = decimalStr.substring(0, size);
		if(roundMode===_roundMode_ROUND_DOWN){
			return parseFloat(integerStr+'.'+outputDecimal);
			//return integerStr+'.'+outputDecimal;
		}
		
		if(roundMode!==_roundMode_ROUND_UP){
			var judgeNum = parseInt(decimalStr.substring(size, size+1),10);
			if(judgeNum<5){
				return parseFloat(integerStr+'.'+outputDecimal);
				//return integerStr+'.'+outputDecimal;
			}
		}

		var outputDecimalTemp = outputDecimal;
		while(outputDecimalTemp.length>0){
			var tempNum = parseInt(outputDecimalTemp.substr(outputDecimalTemp.length-1, 1), 10);
			outputDecimalTemp = outputDecimalTemp.substring(0, outputDecimalTemp.length-1);
			if(tempNum<9){
				tempNum++;
				outputDecimalTemp+=tempNum.toString();
				break;
			}

		}

		var result = parseFloat(integerStr+'.'+outputDecimalTemp);
		if(outputDecimalTemp.length==0){
			result++;
		}
		return result;
	}

	return {
		/**
		 *	@public
		 *	@class 對兩個數字進行加法運算
		 *	@param one 第一個數字
		 *	@param two 第二個數字
		 *	@return result 兩數字相加的結果
		 *	@author 
		 *	@version 1.00
		 **/
		Add : function(one,two) {
			var parttwo = 0;
			
			one = String(one).split('.');
			if (one[1]) {
				if (parseFloat(one[0] + '.' + one[1]) < 0) {
					one[2] = - parseFloat(one[1]);
				} else {
					one[2] = parseFloat(one[1]);
				}
			}
			
			two = String(two).split('.');
			if (two[1]) {
				if (parseFloat(two[0] + '.' + two[1]) < 0) {
					two[2] = - parseFloat(two[1]);
				} else {
					two[2] = parseFloat(two[1]);
				}
			}
			var fix = 0;
			if (one[2] && two[2]) {
				var tempnum = two[2] * Math.pow(10,one[1].length - two[1].length);
				parttwo = (one[2] + tempnum) / Math.pow(10,one[1].length);
				fix = Math.max(one[1].length, two[1].length);
			} else if (one[1]) {
				parttwo = one[2] / Math.pow(10,one[1].length);
				fix = one[1].length;
			} else if (two[1]) {
				parttwo = two[2] / Math.pow(10,two[1].length);
				fix = two[1].length;
			}
			var sum = parseFloat(one[0]) + parseFloat(two[0]) + parttwo;
			return parseFloat(sum.toFixed(fix));
		},
		/**
		 *	@public
		 *	@class 對兩個數字進行減法運算
		 *	@param one 第一個數字
		 *	@param two 第二個數字
		 *	@return result 兩數字相減的結果
		 *	@author 
		 *	@version 1.00
		 **/
		Subtract : function(one,two) {
			return MathExt.Add(one,-two);
		},
		/**
		 *	@public
		 *	@class 對兩個數字進行乘法運算
		 *	@param one 第一個數字
		 *	@param two 第二個數字
		 *	@return result 兩數字相乘的結果
		 *	@author 
		 *	@version 1.00
		 **/
		Multiply : function(one,two) {
			var parttwo = 0;
			
			one = String(one).split('.');
			if (one[1]) {
				if (parseFloat(one[0] + '.' + one[1]) < 0) {
					one[1] = - parseFloat('0.' + one[1]);
				} else {
					one[1] = parseFloat('0.' + one[1]);
				}
			}
			
			two = String(two).split('.');
			if (two[1]) {
				if (parseFloat(two[0] + '.' + two[1]) < 0) {
					two[1] = - parseFloat('0.' + two[1]);
				} else {
					two[1] = parseFloat('0.' + two[1]);
				}
			}
			
			if (one[1] && two[1]) {
				parttwo = one[1] * two[1];
			}
			if (one[1]) {
				parttwo = MathExt.Add(parttwo,parseFloat(two[0]) * one[1]);
			}
			if (two[1]) {
				parttwo = MathExt.Add(parttwo,parseFloat(one[0]) * two[1]);
			}
			
			return parseFloat(one[0]) * parseFloat(two[0]) + parttwo;
		},
		/**
		 *	@public
		 *	@class 對兩個數字進行除法運算
		 *	@param one 第一個數字
		 *	@param two 第二個數字
		 *	@return result 第一數字除以第二個數字的結果
		 *	@author 
		 *	@version 1.00
		 **/
		Divide : function(one,two) {
			return MathExt.Multiply(one,1 / two);
		},
		/**
		 *	@public
		 *	@class 計算一數字，以一底數為基的對數值 (若底數傳入非數字，則預設為10)
		 *	@param one 數字
		 *	@param two 底數
		 *	@return result 第一數字以第二個數字為底數的log結果
		 *	@author 
		 *	@version 1.00
		 **/
		Log : function(one,two) {
			if (isNaN(two)) {
				two = 10;
			}
			return MathExt.Divide(Math.log(one),Math.log(two));
		},
		/**
		 *	@public
		 *	@class 計算一數字，開n次方根的值 (若n傳入非數字，則預設為2，即預設計算為平方根)
		 *	@param number 數字
		 *	@param size (n值)
		 *	@return result 數字開n次方根的結果
		 *	@author 
		 *	@version 1.00
		 **/
		Root : function(number,size) {
			if (isNaN(size)) {
				size = 2;
			}
			return Math.pow(number,MathExt.Divide(1,size));
		},
		/**
		 *	@public
		 *	@class 將一數字以四捨五入的方式取到小數第n位 (若n傳入非數字，則預設為0，即取到整數位)
		 *	@param number 數字
		 *	@param size (n值)
		 *	@return result 數字四捨五入到小數第n位的結果
		 *	@author 
		 *	@version 1.00
		 **/
		Round : function(number,size) {
			return handleRound(number, size, _roundMode_ROUND_HALF_UP);
		},
		/**
		 *	@public
		 *	@class 將一數字以無條件進位的方式取到小數第n位 (若n傳入非數字，則預設為0，即取到整數位)
		 *	@param number 數字
		 *	@param size (n值)
		 *	@return result 數字無條件進位到小數第n位的結果
		 *	@author 
		 *	@version 1.00
		 **/
		Ceil : function(number,size) {
			return handleRound(number, size, _roundMode_ROUND_UP);
		},
		/**
		 *	@public
		 *	@class 將一數字以無條件捨去的方式取到小數第n位 (若n傳入非數字，則預設為0，即取到整數位)
		 *	@param number 數字
		 *	@param size (n值)
		 *	@return result 數字無條件捨去到小數第n位的結果
		 *	@author 
		 *	@version 1.00
		 **/
		Floor : function(number,size) {
			return handleRound(number, size, _roundMode_ROUND_DOWN);
		},
		/**
		 *	@public
		 *	@class 將一個帶有單位與科學記號的文字轉為一般數字,例如1ke2轉換後為100000
		 *	@param string 文字
		 *  @param comma 小數點的表示符號是否為逗點,預設為.號
		 *  @param noreplace 是否要將單位轉換為數字,例如3k轉換後為3000,預設為要轉換
		 *  @param prefix 單位詞頭表 (預設使用 International System of Units 國際單位制，簡稱 SI)
		 *	@return result 將數字轉換為n進位的結果
		 *	@author 
		 *	@version 1.00
		 **/
		FromString : function(string,comma,noreplace,prefix) {
			var numbers = new Array();
			numbers['0'] = 0; numbers['1'] = 1; numbers['2'] = 2; numbers['3'] = 3; numbers['4'] = 4; numbers['5'] = 5; numbers['6'] = 6; numbers['7'] = 7; numbers['8'] = 8; numbers['9'] = 9;
			if (!prefix) {
				prefix = new Array();
				prefix['Y'] = 1000000000000000000000000; prefix['Z'] = 1000000000000000000000; prefix['E'] = 1000000000000000000; prefix['P'] = 1000000000000000; prefix['T'] = 1000000000000; prefix['G'] = 1000000000; prefix['M'] = 1000000; prefix['k'] = 1000; prefix['h'] = 100; prefix['d'] = 0.1; prefix['c'] = 0.01; prefix['m'] = 0.001; prefix['μ'] = 0.000001; prefix['n'] = 0.000000001; prefix['p'] = 0.000000000001; prefix['f'] = 0.000000000000001; prefix['a'] = 0.000000000000000001; prefix['z'] = 0.000000000000000000001; prefix['y'] = 0.000000000000000000000001;
			}
			
			var dot = 0;
			var j = 0;
			var minus = 1;
			var partone = 0;
			var parttwo = 0;
			
			for (var i = 0; i < string.length; i++) {
				if (string.substr(i,1) == 'e' || string.substr(i,1) == 'E') {
					var parts = MathExt.Add(partone,parttwo / Math.pow(10,j));
					var exponent = MathExt.FromString(string.substr(i + 1),comma,noreplace,prefix);
					return minus * MathExt.Multiply(parts,Math.pow(10,exponent));
				} else if (!dot) {
					if (string.substr(i,1) == '-' && !partone) {
						minus = - minus;
					} else if (numbers[string.substr(i,1)] || numbers[string.substr(i,1)] == '0') {
						partone = partone * 10 + numbers[string.substr(i,1)];
					} else if (string.substr(i,1) == '.' && !comma || string.substr(i,1) == ',' && comma) {
						dot = 1;
					} else if (prefix[string.substr(i,1)] && !noreplace) {
						partone *= prefix[string.substr(i,1)];
					}
				} else {
					if (numbers[string.substr(i,1)] || numbers[string.substr(i,1)] == '0') {
						parttwo = parttwo * 10 + numbers[string.substr(i,1)];
						j++;
					} else if (prefix[string.substr(i,1)] && !noreplace) {
						parttwo *= prefix[string.substr(i,1)];
					}
				}
			}
			return minus * MathExt.Add(partone,parttwo / Math.pow(10,j));
		},
		/**
		 *	@public
		 *	@class 將數字轉換為文字 (可包含科學符號e)
		 *	@param number 文字
		 *  @param comma 小數點要用逗號還是點號表示 (預設為點號)
		 *  @param exponent 是否要處理指數,base為10 (預設為要,傳true為不處理)
		 *	@return result 將數字轉換為文字的結果
		 *	@author 
		 *	@version 1.00
		 **/
		ToString : function(number,comma,exponent) {
			var string = new String(number);
			
			if (!exponent) {		
				var eArray = string.split('e');					
				if (eArray[1]) {							
					eArray[1] = parseFloat(eArray[1]);			
					var minus = false;
					if( eArray[0].length > 0 && eArray[0].substring(0,1) == "-" ){
						eArray[0] = eArray[0].substr(1);
						minus = true;
					}
					
					var XeArray = eArray[0].split('.');			
					if (XeArray[1]) {							
						eArray[0] = XeArray[0] + XeArray[1];
					}
					eArray[1] += XeArray[0].length; 
					
					string = eArray[0];	
					if( eArray[1] > 0 ){
						if( eArray[1] >= string.length ){				
							var length = eArray[1] - string.length;		//計算超出的個數
							string = string.replace(/^0*/g , "" );	
							for (var i = 0; i < length; i++) {
								string += '0';
							}
						}else{
							var section1 = string.substr(0,eArray[1]).replace(/^0*/g , "");
							var section2 = string.substr(eArray[1]);
							if(section1.length == 0 ){
								section1 = "0";
							}
							string = section1 + "." + section2;
						}
					}else{	//0.xxxx的狀況
						for (var i = 0; i < - eArray[1]; i++) {
							string = '0' + string;
						}
						string = '0.' + string;
					}
					
					if( minus ){
						string = "-" + string;
					}
				}
			}
			
			if (comma) {
				var cArray = string.split('.');
				if (cArray[1]) {
					string = cArray[0] + ',' + cArray[1];
				}
			}
			
			return string;
		},
		/**
		 *	@public
		 *	@class 將一數字以n進位的方式呈現 
		 *	@param number 數字
		 *	@param to (n值)
		 *	@return result 將數字轉換為n進位的結果
		 *	@author 
		 *	@version 1.00
		 **/
		FromDecimal : function(number,to) {
			Math.round(to);
			if (to == 10) {
				return MathExt.ToString(number);
			}
			
			var chars = new Array();
			chars[0] = '0'; chars[1] = '1'; chars[2] = '2'; chars[3] = '3'; chars[4] = '4'; chars[5] = '5'; chars[6] = '6'; chars[7] = '7'; chars[8] = '8'; chars[9] = '9'; chars[10] = 'A'; chars[11] = 'B'; chars[12] = 'C'; chars[13] = 'D'; chars[14] = 'E'; chars[15] = 'F'; chars[16] = 'G'; chars[17] = 'H'; chars[18] = 'I'; chars[19] = 'J'; chars[20] = 'K'; chars[21] = 'L'; chars[22] = 'M'; chars[23] = 'N'; chars[24] = 'O'; chars[25] = 'P'; chars[26] = 'Q'; chars[27] = 'R'; chars[28] = 'S'; chars[29] = 'T'; chars[30] = 'U'; chars[31] = 'V'; chars[32] = 'W'; chars[33] = 'X'; chars[34] = 'Y';  chars[35] = 'Z';
			
			var minus = '';
			if (number < 0) {
				minus = '-';
				number = - number;
			}
			
			var string = '';
			while (number) {
				number = String(number /to).split('.');
				string = chars[Math.round(MathExt.Multiply(parseFloat('0.' + number[1]),to))] + string;
				number = parseFloat(number[0]);
			}
			return minus + string;
		},
		/**
		 *	@public
		 *	@class 將一n進位的數字,轉回10進位數字
		 *	@param string 數字
		 *	@param from (n值)
		 *	@return result 將數字轉換為10進位的結果
		 *	@author 
		 *	@version 1.00
		 **/
		ToDecimal : function(string,from) {
			Math.round(from);
			if (from == 10) {
				return MathExt.FromString(string);
			}
			
			var chars = new Array();
			chars['0'] = 0; chars['1'] = 1; chars['2'] = 2; chars['3'] = 3; chars['4'] = 4; chars['5'] = 5; chars['6'] = 6; chars['7'] = 7; chars['8'] = 8; chars['9'] = 9; chars['A'] = 10; chars['B'] = 11; chars['C'] = 12; chars['D'] = 13; chars['E'] = 14; chars['F'] = 15; chars['G'] = 16; chars['H'] = 17; chars['I'] = 18; chars['J'] = 19; chars['K'] = 20; chars['L'] = 21; chars['M'] = 22; chars['N'] = 23; chars['O'] = 24; chars['P'] = 25; chars['Q'] = 26; chars['R'] = 27; chars['S'] = 28; chars['T'] = 29; chars['U'] = 30; chars['V'] = 31; chars['W'] = 32; chars['X'] = 33; chars['Y'] = 34; chars['Z'] = 35;
			
			var j = 0;
			var minus = 1;
			var number = 0;
			
			string.toUpperCase();
			for (var i = string.length - 1; i >= 0; i--) {
				if (chars[string.substr(i,1)] || chars[string.substr(i,1)] == '0') {
					number += chars[string.substr(i,1)] * Math.pow(from,j);
					j++;
					minus = 1;
				} else if (string.substr(i,1) == '-') {
					minus = - minus;
				}
			}
			return minus * number;
		},
		/**
		 *	@public
		 *	@class 將羅馬數字(Roman Number)轉換為一般數字,例如 XI 轉換後為 11  
		 *	@param 要轉換的羅馬數字
		 *	@return result 轉換結果 (無法正確轉換回傳為NaN)
		 *	@author 
		 *	@version 1.00
		 **/
		FromRoman : function(roman) {
			var chars = new Array();
			chars['N'] = 1000000; chars['O'] = 500000; chars['P'] = 100000; chars['Q'] = 50000; chars['R'] = 10000; chars['S'] = 5000; chars['M'] = 1000; chars['D'] = 500; chars['C'] = 100; chars['L'] = 50; chars['X'] = 10; chars['V'] = 5; chars['I'] = 1;
			
			var decimal = 0;
			var minus = 1;
			var state = 0;
			
			roman.toUpperCase();
			for (var i = roman.length - 1; i >= 0; i--) {
				if (roman.substr(i,1) == '-') {
					minus = - minus;
				} else if (state > chars[roman.substr(i,1)]) {
					decimal -= chars[roman.substr(i,1)];
					minus = 1;
				} else {
					decimal += chars[roman.substr(i,1)];
					state = chars[roman.substr(i,1)];
					minus = 1;
				}
			}
			return minus * decimal;
		},
		/**
		 *	@public
		 *	@class 將一般數字轉換為羅馬數字(Roman Number),例如 11 轉換後為 XI  
		 *	@param 要轉換的數字
		 *	@return result 轉換結果
		 *	@author 
		 *	@version 1.00
		 **/
		ToRoman : function(number) {
			Math.round(number);
			var chars = new Array();
			chars['N'] = 1000000; chars['O'] = 500000; chars['P'] = 100000; chars['Q'] = 50000; chars['R'] = 10000; chars['S'] = 5000; chars['M'] = 1000; chars['D'] = 500; chars['C'] = 100; chars['L'] = 50; chars['X'] = 10; chars['V'] = 5; chars['I'] = 1;
			
			var last = '';
			var roman = '';
			if (number < 0) {
				roman = '-';
				number = - number;
			}
			
			for (var letter in chars) {
				var decimal = chars[letter];
				var temp = '';
				while (number >= decimal) {
					number -= decimal;
					temp += letter;
				}
				if (last && temp.length == 4) {
					temp = letter + last;
				} else if (temp == '' && number > (0.8 * decimal)) {
					temp = MathExt.ToRoman( - (number - decimal)) + letter;
					number = 0;
				}
				last = letter;
				roman += temp;
			}
			return roman;
		}
	}; 
};