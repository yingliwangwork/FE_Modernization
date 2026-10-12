(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    /*AMD. Register as an anonymous module.
    *define([], factory); */
    define([], factory());
  } else if (typeof module === 'object' && module.exports) {
    /*Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.*/
    module.exports = factory();

  } else {
    /*Browser globals (root is window)*/
    root['watermark'] = factory();
  }
}(this, function () {
	/**
	 * watermark-dom v 2.3.0 (2019.12.14)
	 *
	 * MIT License
	 * 
	 * Copyright (c) 2017 saucxs
	 */


  /*Just return a value to define the module export.*/
  var watermark = {};

  var defaultSettings = {
    watermark_id: 'wm_div_id',          //水印總體的id
    watermark_prefix: 'mask_div_id',    //小水印的id前綴
    watermark_txt: '內部畫面 嚴禁外流 查獲屬實送人管單位處分',         //水印的內容
    watermark_personal_info_txt: '',     //水印的個資資訊內容
    watermark_datetime: '',              //水印的時間資訊內容
    watermark_x: -250,                     //水印起始位置x軸坐標
    watermark_y: -200,                     //水印起始位置Y軸坐標
    watermark_rows: 1,                  //水印行數
    watermark_cols: 1,                   //水印列數
    watermark_x_space: 5,               //水印x軸間隔
    watermark_y_space: 5,               //水印y軸間隔
    watermark_font: '微軟雅黑',          //水印字體
    watermark_color: 'black',            //水印字體顏色
    watermark_fontsize: '2rem',          //水印字體大小
    watermark_alpha: 0.1,               //水印透明度，要求設置在大於等於0.005
    watermark_width: 800,                //水印寬度
    watermark_height: 300,               //水印高度
    watermark_evenCol_tran_height: 100,  //偶數水印位置增加位移
    watermark_angle: 25,                 //水印傾斜度數
    watermark_parent_width: 0,      //水印的總體寬度（默認值：body的scrollWidth和clientWidth的較大值）
    watermark_parent_height: 0,     //水印的總體高度（默認值：body的scrollHeight和clientHeight的較大值）
    watermark_parent_node: null,     //水印插件掛載的父元素element,不輸入則默認掛在body上
    monitor: true,                   //monitor 是否監控， true: 不可刪除水印; false: 可刪水印。
  };


  /*加載水印*/
  var loadMark = function (settings) {
    /*採用配置項替換默認值，作用類似jquery.extend*/
    if (arguments.length === 1 && typeof arguments[0] === "object") {
      var src = arguments[0] || {};
      for (key in src) {
        if (src[key] && defaultSettings[key] && src[key] === defaultSettings[key]) continue;
        /*veronic: resolution of watermark_angle=0 not in force*/
        else if (src[key] || src[key] === 0) defaultSettings[key] = src[key];
      }
    }

    /*如果元素存在則移除*/
    var watermark_element = document.getElementById(defaultSettings.watermark_id);
    watermark_element && watermark_element.parentNode && watermark_element.parentNode.removeChild(watermark_element);

    /*如果設置水印掛載的父元素的id*/
    var watermark_parent_element = document.getElementById(defaultSettings.watermark_parent_node);
    var watermark_hook_element = watermark_parent_element ? watermark_parent_element : document.body;

    /*獲取頁面寬度*/
    // var page_width = Math.max(watermark_hook_element.scrollWidth,watermark_hook_element.clientWidth) - defaultSettings.watermark_width/2;
    var page_width = Math.max(watermark_hook_element.scrollWidth, watermark_hook_element.clientWidth);
    /*獲取頁面最大長度*/
    // var page_height = Math.max(watermark_hook_element.scrollHeight,watermark_hook_element.clientHeight,document.documentElement.clientHeight)-defaultSettings.watermark_height/2;
    var page_height = Math.max(watermark_hook_element.scrollHeight, watermark_hook_element.clientHeight);

    var setting = arguments[0] || {};
    var parentEle = watermark_hook_element;

    var page_offsetTop = 0;
    var page_offsetLeft = 0;
    if (setting.watermark_parent_width || setting.watermark_parent_height) {
      /*指定父元素同時指定了寬或高*/
      if (parentEle) {
        page_offsetTop = parentEle.offsetTop || 0;
        page_offsetLeft = parentEle.offsetLeft || 0;
        defaultSettings.watermark_x = defaultSettings.watermark_x + page_offsetLeft;
        defaultSettings.watermark_y = defaultSettings.watermark_y + page_offsetTop;
      }
    } else {
      if (parentEle) {
        page_offsetTop = parentEle.offsetTop || 0;
        page_offsetLeft = parentEle.offsetLeft || 0;
      }
    }

    /*創建水印外殼div*/
    var otdiv = document.getElementById(defaultSettings.watermark_id);
    var shadowRoot = null;

    if (!otdiv) {
      otdiv = document.createElement('div');
      /*創建shadow dom*/
      otdiv.id = defaultSettings.watermark_id;
      otdiv.setAttribute('style', 'pointer-events: none !important; display: block !important');
      /*判斷瀏覽器是否支持attachShadow方法*/
      if (typeof otdiv.attachShadow === 'function') {
        /* createShadowRoot Deprecated. Not for use in new websites. Use attachShadow*/
        shadowRoot = otdiv.attachShadow({ mode: 'open' });
      } else {
        shadowRoot = otdiv;
      }
      /*將shadow dom隨機插入body內的任意位置*/
      var nodeList = watermark_hook_element.children;
      var index = Math.floor(Math.random() * (nodeList.length - 1));
      if (nodeList[index]) {
        watermark_hook_element.insertBefore(otdiv, nodeList[index]);
      } else {
        watermark_hook_element.appendChild(otdiv);
      }
    } else if (otdiv.shadowRoot) {
      shadowRoot = otdiv.shadowRoot;
    }
    /*三種情況下會重新計算水印列數和x方向水印間隔：1、水印列數設置為0，2、水印寬度大於頁面寬度，3、水印寬度小於於頁面寬度*/
    defaultSettings.watermark_cols = parseInt((page_width - defaultSettings.watermark_x) / (defaultSettings.watermark_width + defaultSettings.watermark_x_space));
    var temp_watermark_x_space = parseInt((page_width - defaultSettings.watermark_x - defaultSettings.watermark_width * defaultSettings.watermark_cols) / (defaultSettings.watermark_cols));
    defaultSettings.watermark_x_space = temp_watermark_x_space ? defaultSettings.watermark_x_space : temp_watermark_x_space;
    var allWatermarkWidth;

    /*三種情況下會重新計算水印行數和y方向水印間隔：1、水印行數設置為0，2、水印長度大於頁面長度，3、水印長度小於於頁面長度*/
    defaultSettings.watermark_rows = parseInt((page_height - defaultSettings.watermark_y) / (defaultSettings.watermark_height + defaultSettings.watermark_y_space));
    var temp_watermark_y_space = parseInt((page_height - defaultSettings.watermark_y - defaultSettings.watermark_height * defaultSettings.watermark_rows) / (defaultSettings.watermark_rows));
    defaultSettings.watermark_y_space = temp_watermark_y_space ? defaultSettings.watermark_y_space : temp_watermark_y_space;
    var allWatermarkHeight;

    if (watermark_parent_element) {
      allWatermarkWidth = defaultSettings.watermark_x + defaultSettings.watermark_width * defaultSettings.watermark_cols + defaultSettings.watermark_x_space * (defaultSettings.watermark_cols - 1);
      allWatermarkHeight = defaultSettings.watermark_y + defaultSettings.watermark_height * defaultSettings.watermark_rows + defaultSettings.watermark_y_space * (defaultSettings.watermark_rows - 1);
    } else {
      allWatermarkWidth = page_offsetLeft + defaultSettings.watermark_x + defaultSettings.watermark_width * defaultSettings.watermark_cols + defaultSettings.watermark_x_space * (defaultSettings.watermark_cols - 1);
      allWatermarkHeight = page_offsetTop + defaultSettings.watermark_y + defaultSettings.watermark_height * defaultSettings.watermark_rows + defaultSettings.watermark_y_space * (defaultSettings.watermark_rows - 1);
    }
	
	if(!defaultSettings.watermark_rows){
		defaultSettings.watermark_rows = 1;
	}
	if(!defaultSettings.watermark_cols){
		defaultSettings.watermark_cols = 1;
	}
	if(!defaultSettings.watermark_x_space){
		defaultSettings.watermark_x_space = 5
	}
	if(!defaultSettings.watermark_y_space){
		defaultSettings.watermark_y_space = 5
	}
	if((page_height - allWatermarkHeight)  > (defaultSettings.watermark_height / 2)){
		defaultSettings.watermark_rows = defaultSettings.watermark_rows + 1;
	}
	if((page_width - allWatermarkWidth)  > (defaultSettings.watermark_width / 2)){
		defaultSettings.watermark_cols = defaultSettings.watermark_cols + 1;
	}
	
    var x;
    var y;
    for (var i = 0; i <= defaultSettings.watermark_rows; i++) {
      if (watermark_parent_element) {
        y = page_offsetTop + defaultSettings.watermark_y + (page_height - allWatermarkHeight) / 2 + (defaultSettings.watermark_y_space + defaultSettings.watermark_height) * i;
      } else {
        y = defaultSettings.watermark_y + (page_height - allWatermarkHeight) / 2 + (defaultSettings.watermark_y_space + defaultSettings.watermark_height) * i;
      }

      for (var j = 0; j <= defaultSettings.watermark_cols; j++) {
        if (watermark_parent_element) {
          x = page_offsetLeft + defaultSettings.watermark_x + (page_width - allWatermarkWidth) / 2 + (defaultSettings.watermark_width + defaultSettings.watermark_x_space) * j;
        } else {
          x = defaultSettings.watermark_x + (page_width - allWatermarkWidth) / 2 + (defaultSettings.watermark_width + defaultSettings.watermark_x_space) * j;
        }
        var mask_div = document.createElement('div');
        var hasText = false;
		if(defaultSettings.watermark_personal_info_txt){
			var personalText = document.createTextNode(defaultSettings.watermark_personal_info_txt);
			mask_div.appendChild(personalText);
			mask_div.appendChild(document.createElement('br'));
			hasText = true;
		}
		if(defaultSettings.watermark_datetime){
			var datetimeText = document.createTextNode(defaultSettings.watermark_datetime);
			mask_div.appendChild(datetimeText);
			mask_div.appendChild(document.createElement('br'));
			hasText = true;
		}
		if(defaultSettings.watermark_txt){
			var datetimeText = document.createTextNode(defaultSettings.watermark_txt);
			mask_div.appendChild(datetimeText);
			mask_div.appendChild(document.createElement('br'));
			hasText = true;
		}
		if(!hasText){
			mask_div.appendChild(document.createTextNode('watermark test'));
		}
		
        /*設置水印相關屬性start*/
        mask_div.id = defaultSettings.watermark_prefix + i + j;
        /*設置水印div傾斜顯示*/
        mask_div.style.webkitTransform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
        mask_div.style.MozTransform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
        mask_div.style.msTransform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
        mask_div.style.OTransform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
        mask_div.style.transform = "rotate(-" + defaultSettings.watermark_angle + "deg)";
        mask_div.style.visibility = "";
        mask_div.style.position = "fixed";
        /*選不中*/
        mask_div.style.left = x + 'px';
        mask_div.style.top = y+ ((j%2==1) ? defaultSettings.watermark_evenCol_tran_height: 0) + 'px';
        mask_div.style.overflow = "hidden";
        mask_div.style.zIndex = "9999999";
        mask_div.style.opacity = defaultSettings.watermark_alpha;
        mask_div.style.fontSize = defaultSettings.watermark_fontsize;
        mask_div.style.fontFamily = defaultSettings.watermark_font;
        mask_div.style.color = defaultSettings.watermark_color;
        mask_div.style.textAlign = "center";
        mask_div.style.width = defaultSettings.watermark_width + 'px';
        mask_div.style.height = defaultSettings.watermark_height + 'px';
        mask_div.style.display = "block";
        mask_div.style['-ms-user-select'] = "none";
        /*設置水印相關屬性end*/
        shadowRoot.appendChild(mask_div);
      }
    }

    // monitor 是否監控， true: 不可刪除水印; false: 可刪水印。
    const minotor = settings.monitor === undefined ? defaultSettings.monitor : settings.monitor;
    if (minotor) {
      watermarkDom.observe(watermark_hook_element, option);
      watermarkDom.observe(document.getElementById(defaultSettings.watermark_id).shadowRoot, option);
    }
  };

  /*移除水印*/
  var removeMark = function () {
    /*採用配置項替換默認值，作用類似jquery.extend*/
    if (arguments.length === 1 && typeof arguments[0] === "object") {
      var src = arguments[0] || {};
      for (key in src) {
        if (src[key] && defaultSettings[key] && src[key] === defaultSettings[key]) continue;
        /*veronic: resolution of watermark_angle=0 not in force*/
        else if (src[key] || src[key] === 0) defaultSettings[key] = src[key];
      }
    }

    /*移除水印*/
    var watermark_element = document.getElementById(defaultSettings.watermark_id);
    var _parentElement = watermark_element.parentNode;
    _parentElement.removeChild(watermark_element);
    // :ambulance: remove()
    // minotor 這個配置有些冗餘
    // 如果用 MutationObserver 來監聽dom變化防止刪除水印
    // remove() 方法裡用 MutationObserver 的 disconnect() 解除監聽即可
    watermarkDom.disconnect();
  };

  var globalSetting;
  /*初始化水印，添加load和resize事件*/
  watermark.init = function (settings) {
    globalSetting = settings;
    loadMark(settings);
    window.addEventListener('onload', function () {
      loadMark(settings);
    });
    window.addEventListener('resize', function () {
      loadMark(settings);
    });
  };

  /*手動加載水印*/
  watermark.load = function (settings) {
    globalSetting = settings;
    loadMark(settings);
  };

  /*手動移除水印*/
  /*watermark.remove = function(){
    removeMark();
  };*/

  //監聽dom是否被移除或者改變屬性的回調函數
  var callback = function (records) {
    if ((globalSetting && records.length === 1) || records.length === 1 && records[0].removedNodes.length >= 1) {
      loadMark(globalSetting);
      return;
    }

    // 監聽父節點的尺寸是否發生了變化, 如果發生改變, 則進行重新繪製
    var watermark_parent_element = document.getElementById(defaultSettings.watermark_parent_node);
    if (watermark_parent_element) {
      var newWidth = getComputedStyle(watermark_parent_element).getPropertyValue('width');
      var newHeight = getComputedStyle(watermark_parent_element).getPropertyValue('height');
      if (newWidth !== recordOldValue.width || newHeight !== recordOldValue.height) {
        recordOldValue.width = newWidth;
        recordOldValue.height = newHeight;
        loadMark(globalSetting);
      }
    }
  };
  const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
  var watermarkDom = new MutationObserver(callback);
  var option = {
    'childList': true,
    'attributes': true,
    'subtree': true,
    'attributeFilter': ['style'],
    'attributeOldValue': true
  };

  var recordOldValue = {
    width: 0,
    height: 0
  };

  return watermark;
}));
