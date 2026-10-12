function html(args){
/*-------------------------------------------------------------------------------------
 * Public Data
 -------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------
 * Public Method
 -------------------------------------------------------------------------------------*/
		this.getid = getid;
		this.getname = getname;
		this.getObjectValue = getObjectValue;
		this.getValue = getValue;
		this.getRadio = getRadio;
		this.getSelect = getSelect;
		this.getSelectObj = getSelectObj;
		this.checkRadio = checkRadio;
		this.clearRadio = clearRadio;
		this.chkSelect = chkSelect;
		this.selectOne = selectOne;
		this.selectOneObj = selectOneObj;
		this.mwo = mwo;
		this.mwa = mwa;
		this.getDaysOffset = my_getDaysOffset;
		this.comp2date = my_comp2date;
		this.comp2time = my_comp2time;
		this.my_escape = my_escape;
		this.fix = fix;
		this.toUppercase = toUppercase;
		this.getPasses = getPasses;
		this.compToToday = compToToday;
		this.fillPreZero = fillPreZero;
		this.fillLastZero = fillLastZero;
		this.getIndexName = getIndexName;
		this.isNumber = isNumber;
		this.DateCheck = DateCheck;
		this.EnDisableType = EnDisableType;
		this.setFix = setScrollObjByName;
		this.setScrollObjByName = setScrollObjByName;
		this.setScrollObjByElement = setScrollObjByElement;
		this.selectAll = selectAll;
		this.ignoreSpaces = ignoreSpaces;
		this.addPrefix = addPrefix;
		this.addNextfix = addNextfix;
		var scrollObj=new Array();
/*-------------------------------------------------------------------------------------
 * Private Method
 -------------------------------------------------------------------------------------*/
		//網頁 body onload(), onScroll(), onResize() 修正用
	 		function setScrollObjByName(ary){
	 			for(var i=0; i<ary.length; i++){
	 				scrollObj[i] = getid(ary[i]); 
	 			}
	 		}
	 		function setScrollObjByElement(ary){
	 			for(var i=0; i<ary.length; i++){
	 				scrollObj[i] = ary[i]; 
	 			}
	 		}
			function stat(){
				var a = pageYOffset+window.innerHeight-document.bar1.document.height-15;
				document.bar1.top = a;
				setTimeout('stat()',2);
			}
			function fix(){
				EnDisableScrollObjs(true); 
				nome=navigator.appName;
				if(nome=='Netscape'){
					stat();
				}else{
					var a=document.body.scrollTop-document.all.bar1.offsetHeight+30;
					bar1.style.top = a;
				}
				EnDisableScrollObjs(false);
			}
			function EnDisableScrollObjs(isDisable){
				var ary = scrollObj;
				if (ary && ary.length){
					for(var i=0; i<ary.length; i++)
						ary[i].disabled = isDisable;
				}
			}

//----------------------------------------------------------------------------			
		/*右側 補 0 */
		function fillPreZero(o, len, isForce){
			var v = o.value;
			var str = "";
			var pad = "0";
			if (v && (v.length > 0) && !isForce){
				for (var i=0; i<len; i++)
					str +=  (i < (len-v.length)) ? pad : v.charAt( Math.abs(len-i-v.length) );
			}
			o.value = str;
		}


//----------------------------------------------------------------------------			
		/*左側 補 0 */

		function fillLastZero(o, len, isForce){
			var v = o.value;
			var str = "";
			var pad = "0";
			if (v && (v.length > 0) && !isForce){
				for (var i=v.length; i<len; i++)
					str +=  (i < len ) ?  pad :  "" ;
			}

			o.value = v + str;
		}


//----------------------------------------------------------------------------			

		function my_getDaysOffset(d, n){
			var one_day=1000*60*60*24;
			var diffDays2nTime = (d.getDay()-4-n) * one_day;
			DayN = new Date(Math.ceil(d.getTime() - diffDays2nTime))
			return DayN; 
		}
//----------------------------------------------------------------------------			

		function my_comp2date(date1, date2, isDisplay){
			var one_day=1000*60*60*24;
			var DaysDiff = Math.ceil((date1.getTime() - date2.getTime()) / one_day);
			if (isDisplay) alert(date1+' - '+date2+' - '+DaysDiff);
			return DaysDiff;
		}
//----------------------------------------------------------------------------			

		function my_comp2time(date1, date2, isDisplay){
			TimesDiff = Math.ceil((date1.getTime() - date2.getTime()));
			if (isDisplay) alert(date1+' - '+date2+' - '+TimesDiff);
			return TimesDiff;
		}
//----------------------------------------------------------------------------			

		function my_escape(fields){
			for(var i=0; i<fields.length; i++)
				eval(fields[i]+' = escape('+fields[i]+')');
		}
//----------------------------------------------------------------------------			

		//檢查參數是否為數值
		function isNumber(o){
			return (typeof(o)=="number");
		}
//----------------------------------------------------------------------------			

		function toUppercase(o){
			o.value = o.value.toUpperCase();
		}

//----------------------------------------------------------------------------			

		
		function mwo(obj,isWrite, div){
			var str = '';
			for(var i in obj)
				str += i+' : '+obj[i]+' / ';
			if (!isWrite) alert(str);
			else div.innerHTML = str;
		}
//----------------------------------------------------------------------------			

		function mwa(va, n){
			//s: walk through array
			var name = (n==null) ? '' : n;
			var str ='';
			if ((va.length)&&(va.length>0)){
				str += (name+' - '+va.length+'\n\n');
				str += '--------------array detail-----------------\n\n';
				for (var i=0; i< va.length; i++)
					str += i+': ['+va[i]+']\n';
			}else str='null array';
			alert(str);
		}
//----------------------------------------------------------------------------			

		function getid(id){
			return document.getElementById(id); 
		}
//----------------------------------------------------------------------------			

		function getname(name){
			return document.getElementsByName(name); 
		}
//----------------------------------------------------------------------------			

		
		/* 取出於 1-n 個同名物件之值 */
		function getObjectValue(o, idx){
			//return (o.length) ? ((o.length>1) ? o[idx].value : v = o.value) : null;
			return  o.value;
		}
//----------------------------------------------------------------------------			

		/* 取出於 1-n 個同名物件之值 */
		function getValue(n, idx){
			var o = this.getname(n);
			//alert("n="+n+"\n o.length= "+o.length+ "\n o.value= "+o.value + "\n o[idx].value= "+o[idx].value );
			return (o.length) ? ((o.length>1) ? o[idx].value : o.value) : null;
		}
//----------------------------------------------------------------------------			

		function getRadio(rdo){
			var v =null;
			if (!rdo.length){
				if (rdo.checked) v = rdo.value;
			}else{	
				for (var i=0; i<rdo.length; i++)
					if (rdo[i].checked) v = rdo[i].value;
			}
			return v;
		}
//----------------------------------------------------------------------------			

		function getSelect(n, isText){
			var aSelect = this.getid(n);
			return (isText) ? aSelect.options[aSelect.selectedIndex].text
			                : aSelect.options[aSelect.selectedIndex].value;
		}
//----------------------------------------------------------------------------			

		function getSelectObj(aSelect, isText){
			return (isText) ? aSelect.options[aSelect.selectedIndex].text
			                : aSelect.options[aSelect.selectedIndex].value;
		}
//----------------------------------------------------------------------------			

		function checkRadio(n, idx){
			var rdo = this.getname(n);
			var v =null;
			if (!rdo.length){
				if (parseInt(idx)==0) rdo.checked = true;
			}else{	
				for (var i=0; i<rdo.length; i++){
					if (parseInt(idx) == i) rdo[i].checked = true;
				}
			}
			return;
		}
//----------------------------------------------------------------------------			










		
		function clearRadio(n){
			var rdo = this.getname(n);
			if (!rdo.length){
				rdo.checked = false;
			}else{	
				for (var i=0; i<rdo.length; i++){
					rdo[i].checked = false;
				}
			}
			return;
		}
//----------------------------------------------------------------------------			

		function chkSelect(n, idx){
			var aSelect = this.getid(n);
			if (idx!= null)
				return (aSelect.selectedIndex > parseInt(idx)) ? true : false;
			else 
				return (aSelect.selectedIndex > -1) ? true : false;
		}
//----------------------------------------------------------------------------			

		function selectOne(n, v, chkIsFound){
			var aSelect = this.getid(n);
			var isFound = false;
			for(var i=0; i<aSelect.options.length; i++)
				if (v == aSelect.options[i].value){
					aSelect.options[i].selected = true;
					isFound = true;
				}
			if (chkIsFound) return isFound;
		}
//----------------------------------------------------------------------------			

		function selectOneObj(aSelect, v, chkIsFound){
			//var v = aSelect.options[aSelect.selectedIndex].value;
			//alert("vvvvvv = "+ v);
			var isFound = false;
			for(var i=0; i<aSelect.options.length; i++){
				//alert("iiiiiiii = "+ i);
				//alert( v == aSelect.options[i].value );
				//if ((v).trim() == (aSelect.options[i].value).trim()){
				if (v == aSelect.options[i].value){
					aSelect.options[i].selected = true;
					//alert(i+ " = " +aSelect.options[i].value);
					isFound = true;
				}
			}
			if (chkIsFound) return isFound;
		}
//----------------------------------------------------------------------------			

		function compToToday (baseDate) {
			today = new Date();		
			today.setHours(0);
			today.setMinutes(0); 
			today.setSeconds(0);
			today.setMilliseconds(0);
			input = baseDate;
			var one_day=1000*60*60*24;
			var DaysDiff = Math.ceil((input.getTime() - today.getTime()) / one_day);
			return DaysDiff; 
		}		
//----------------------------------------------------------------------------			

		
		// 證件種類
		function getPasses(){
			var aryPassws = ['身份證','軍人證','護照','台胞證','港人證','稅務編號'];
			return aryPassws;
		}
//----------------------------------------------------------------------------			

		
		function DateCheck(d) {
			var year, month, day;
			/*設定每個月的天數*/
			var days = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );
			date = new String(d);
			/*判斷長度*/
			if (date.length != 8) {
				return false;
			}else{
					year = parseInt(date.substring(0, 4));
					/*因為開頭為0javascript會視為8進位
					所以額外判別*/			
					if (date.substring(4, 5) == "0"){ 
						month = parseInt(date.substring(5, 6));
					}else{
						month = parseInt(date.substring(4, 6));		
					}
					if (date.substring(6,7) == "0"){	
						day = parseInt(date.substring(7, 8));
					}else{
						day = parseInt(date.substring(6, 8));			
					}
					/*判斷是不是有效的數字*/
					if (year == "NaN" || month == "NaN" || day == "NaN"){
						return false;
					}
								
					/*判斷是不是有效的月份*/
					if (month > 12){
						return false;	
					}
					/*判斷是不是閏年*/
					if (isLeapYear(year)) {
						days[1] = 29;
					}
					
					/*判斷是不是有效的天數*/
					if (days[month - 1] < day || day < 1) {
						return false;
					}						
				}
				/*全部檢查完沒問題,傳回true*/
				return true;
		}
//----------------------------------------------------------------------------			

		function getIndexName(idx, ary){
			var name = "";
			for(var i=0; i<ary.length; i++){ if (ary[i][0]==idx) name = ary[i][1]; }
			return name;
		}
//----------------------------------------------------------------------------			

		function isDate(srcData){
			data = srcData.match(/^(\d{4})(\d{2})(\d{2})$/);
			if(!data||!srcData)return false;
			d = new Date(RegExp.$1+"/"+RegExp.$2+"/"+RegExp.$3);
			if(d.getMonth()!=(RegExp.$2-1)||d.getDate()!=RegExp.$3){
				return false
			}
			return true;	
		}
//----------------------------------------------------------------------------			

		function EnDisableType(obj, aType, isDisable, isDebug){
			var disableCnt = 0;
			var str ="";
			for(var i=0; i<obj.length; i++){
				var o = obj[i];
				var bType = (o.type);
				str += bType+ "/";
				if (aType==bType)
				{
					disableCnt++;
					o.disabled = isDisable;
				}
			}
			if (isDebug)alert("str="+str);
		}
//----------------------------------------------------------------------------			

		/*全選*/
		function selectAll(o){
			if (o){
				if (o.length){
				    for (var i = 0; i < o.length; i++)
			          o[i].checked = !o[i].checked;
			    }
		    }
		}
//----------------------------------------------------------------------------			
		/* 忽略 Spaces */	
		function ignoreSpaces(string) {
			var temp = "";
			string = '' + string;
			splitstring = string.split(" ");
			for(i = 0; i < splitstring.length; i++)
			temp += splitstring[i];
			return temp;
		}
		
//-----------------------------------------------------------------------------
	//將欄位前補prestr成長度length的字串 ex A='5' ->addprefix(A,5,'0')->A='00005'
	function addPrefix(str,len,prestr)
	{
		len = parseInt(len);
		while (str.length<len)	str=prestr+str;
		return str;
	}

//-----------------------------------------------------------------------------


	//將欄位後補nextstr成長度length的字串 ex A='5' ->addprefix(A,5,'0')->A='00005'
	function addNextfix(str,len,prestr)
	{
		len = parseInt(len);
		while (str.length<len)	str=+str+prestr;
		return str;
	}

}
