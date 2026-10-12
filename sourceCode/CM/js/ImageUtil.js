
var ImageUtil = {

	/**
	 *  @public
	 *	@class 利用所傳入之圖示存放路徑將其顯示對指定之 DIV 內。
	 *	@param options :
	 *	       選項物件參數說明如下 :
	 *	         options.imagePath : 圖示之存放路徑。
	 *	         options.showImageDivId : 顯示圖示之 DIV ID。
	 *	         options.imageWidth : 圖示寬度。
	 *	         options.imageHeight : 圖示高度。
	 *	         options.imageVspace : 圖示上下之空白間距。
	 *	         options.imageHspace : 圖示左右之空白間距。
	 *	         options.align : 圖示對齊方式。
	 *	         options.imageAlt : 滑鼠移至圖示上顯示之名稱。
	 *	@author 劉本傑
	 *	@version 1.00
	 **/
	showImage: function(options){

		var imagePath = options.imagePath;
		var showImageDivId = options.showImageDivId;
		var imageWidth = options.imageWidth||100;
		var imageHeight = options.imageHeight||100;
		var imageVspace = options.imageVspace||0;
		var imageHspace = options.imageHspace||0;
		var align = options.align;
		var imageAlt = options.imageAlt;

	    var css = $$('head link[href$=css]');
	    var base;
	    if(css.length > 0){
	    	var cssObj = css[0];
			var i = cssObj.href.indexOf('html');
			base = cssObj.href.substring(0, i);
			var docsStrIndex = base.indexOf('Docs');
			if(docsStrIndex>0){
				base = base.substring(0, docsStrIndex)+'Web/';
			}
	    }else{
	    	base = "/ZRWeb/";
	    }

	    var actionTarget = base+"html/CM/ShowImage.jsp";
			actionTarget+='?IMAGE_PATH='+encodeURI(imagePath);

		// 顯示圖示之 ID，再加上 DIV id 以保持顯示圖示 ID 之唯一性
		var imageId = "_ImageUtilImageName_"+showImageDivId;

		var oImage = document.getElementById(imageId);
		var imageDivObj = document.getElementById(showImageDivId);

		if(!oImage){
			oImage = document.createElement("img");
			oImage.setAttribute("id",imageId);
			imageDivObj.appendChild(oImage);			
		}

		oImage.setAttribute("width",imageWidth);
		oImage.setAttribute("height",imageHeight);
		oImage.setAttribute("vspace",imageVspace);
		oImage.setAttribute("hspace",imageHspace);

		if(imageAlt){
			oImage.setAttribute("alt",imageAlt);
		}else{
			oImage.removeAttribute("alt");
		}

		if(align){
			oImage.setAttribute("align",align);
		}else{
			oImage.removeAttribute("align");
		}

		oImage.setAttribute("src",actionTarget);

	}

};