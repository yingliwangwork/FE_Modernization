/*
 *輸入完成後自動跳至下一個指定文字欄位(AutoSkip)
 */
	var autoSkipSequenceArray = new Array();

	/*
	 *將想要自動移入的文字物件reference,依照順序當成參數傳入,如
	 *addElement(document.getElementById('t1'),document.getElementById('t2'),document.getElementById('t3'));
	 *此時,當t1輸入的文字長度等於該欄位所規定的maxlength後,將自動移至t2做輸入
	 */
	function addAutoSkipSequenceElement(){
		var inputLen = arguments.length;
		for(var i = 0;i< inputLen;i++){
			autoSkipSequenceArray.push(arguments[i]);
			addAutoSkipHandler(arguments[i]);
		}
	}

	/*event handler function for auto skip*/
	function addAutoSkipHandler(o){
		o.onkeyup= autoSkipHandler;
	}

	/*event handler function for auto skip*/
	function autoSkipHandler(){

		var field = window.event.srcElement;

		/*skip textarea*/
		if(field.type=='textarea')
			return false;

		/*先判斷文字欄位長度,maxLength 預設值為2147483647,*/
		var maxLen = field.maxLength!=2147483647 ? field.maxLength: field.size? field.size : 6553555 ;
		var inputLen = field.value ? field.value.length : 0;
		if(inputLen < maxLen){
			return true;
		}

		/*必須不是特殊控制碼才執行本動作,並不是所有key code都要*/
		key = window.event.keyCode;
		if(  48 > key ) return true;

		/*當輸入長度等於最長長度後,自動focus下一個欄位*/
		if(inputLen == maxLen){
			for(var i = 0;i<autoSkipSequenceArray.length;i++){
				if(field.name == autoSkipSequenceArray[i].name){
					if(autoSkipSequenceArray[i+1]){
						autoSkipSequenceArray[i+1].focus();
						if(autoSkipSequenceArray[i+1].select) autoSkipSequenceArray[i+1].select();
					}
				}
			}
		}
	}
/**********************************************************************************/
/*auto skip for all input field*/
function addAllAutoSkipElementHandler(d){
	d.onkeyup = allAutoSkipElementHandler;
}
function allAutoSkipElementHandler(){
	var field = event.srcElement; //input 欄位
	/*skip textarea*/
	if(field.type=='textarea')
		return false;

	/*先判斷文字欄位長度,maxLength 預設值為2147483647,*/
	var maxLen = field.maxLength!=2147483647 ? field.maxLength: field.size? field.size : 6553555 ;
	var inputLen = field.value ? field.value.length : 0;
	if(inputLen < maxLen){
		return true;
	}

	/*必須不是特殊控制碼才執行本動作,並不是所有key code都要*/
	key = window.event.keyCode;
	if(  48 > key ) return true;

	for (var i = 0, allEles=document.getElementsByTagName("*"), allElesLength = allEles.length; i < allElesLength; i++){//掃過document包含的所有物件
		var e = allEles[i];
		if (field == e){	//找到目前游標位置所擁有的index
			var currentIndex = i + 2; //準備開始移至它下一個物件
			var exitIndex = currentIndex; //避免無窮迴圈
			while(true){//跑無窮迴圈,當element的條件為false,則自動再往下一個前進,直到是一個可以編輯的欄位才停止
				e = allEles[currentIndex];
				var type = e? (e.type? e.type: '') : '';  //如果是input欄位且readonly,disabled都為false才能把游標移到它身上
				if(e && (type=='text' || type=='select-one'|| type=='radio' || type=='file'|| type=='checkbox')){
					if( !e.readOnly && !e.disabled){
						e.focus();
						if(e.select) e.select();
						break;
					}
				}else if (e && (type=='button')){
					if(exitIndex < allElesLength)  {
						if(e.name=='action_query'){
							tmpE = allEles[currentIndex + 1];
							if( !tmpE.readOnly && !tmpE.disabled){
								tmpE.focus();
								if(tmpE.select) tmpE.select();
								break;
							}else{
								tmpE = allEles[currentIndex + 3];
								tmpE.focus();
								if(tmpE.select) tmpE.select();
								break;
							}
						}
					}
				}
				if(exitIndex > allElesLength) break;
				//index + 1 並且避免index超過最大值
				currentIndex = (currentIndex + 2) % allElesLength;
			}
			return false;
		}
	}
}
/**********************************************************************************/

/*
*利用tab移至可輸入的欄位,如果是readonly則不移入
*/
	/*event handler function for tab */
	function addNextElementHandler(d){
		d.onkeydown = nextElementHandler;
	}

	/*event handler function for tab */
	function nextElementHandler(){
		key = window.event.keyCode;
     	if(key == 9){  //"TAB" keycode ,我們抓到這個event了!
			var field = event.srcElement; //按下tab時的游標所停留的input欄位

			for (var i = 0, allEles=document.getElementsByTagName("*"), allElesLength = allEles.length; i < allElesLength; i++){//掃過document包含的所有物件
				var e = allEles[i];
				if (field == e){//找到目前游標位置所擁有的index
					var currentIndex = i+1; //準備開始移至它下一個物件
					var exitIndex = currentIndex;//避免無窮迴圈
					while(true){//跑無窮迴圈,當element的條件為false,則自動再往下一個前進,直到是一個可以編輯的欄位才停止
						e = allEles[currentIndex];
						var type = e? (e.type? e.type: '') : '';  //如果是input欄位且readonly,disabled都為false才能把游標移到它身上
						if(e && (type=='text' ||type=='textarea' || type=='select-one'|| type=='radio'|| type=='button'|| type=='file'|| type=='checkbox')){
							if( !e.readOnly && !e.disabled){
								e.focus();if(e.select) e.select();
								break;
							}
						}
						if(exitIndex++ > allElesLength) break;
						//index + 1 並且避免index超過最大值
						currentIndex = (currentIndex + 1) % allElesLength;
					}
					return false;
				}
			}
		}
	}