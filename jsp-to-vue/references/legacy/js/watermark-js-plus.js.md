# watermark-js-plus.js 公開契約

**原始資源**: `/CM/js/ui/watermark-js-plus.js`（第三方套件 `watermark-js-plus` v1.6.0，MIT License）

> 本檔為第三方套件之完整原始碼（1271 行），本文件僅記錄專案內唯一呼叫方 `header.jsp` 實際用到的建構子（`WatermarkPlus.Watermark`）選項與 `create()` 方法；建構子完整支援之選項清單已由原始碼之預設值物件清楚判讀，一併記錄以利日後其他頁面沿用時查閱，但套件其餘能力（ex: `BlindWatermark`、`ImageWatermark`、`decode` 等）不在本文件範圍內。

## WatermarkPlus.Watermark(options)
**使用情境**: 建立個人化浮水印實例
**使用方式**: `new WatermarkPlus.Watermark({ ... })`
**主要功能**:
- 將傳入之 `options` 與套件內建預設值合併（傳入值優先），建立浮水印實例，供呼叫 [create()](#create) 顯示
**輸入**:
- `contentType` [String = `"text"`] - 浮水印內容型態，可為 `"text"`、`"multi-line-text"`、`"rich-text"`、`"image"`；`header.jsp` 傳入 `"multi-line-text"`
- `content` [String = `"內部畫面 嚴禁外流 查獲屬實送人管單位處分"`] - 浮水印顯示內容；`contentType` 為文字類型時須為非空字串。`header.jsp` 傳入使用者識別文字與 [watermark_datetime](../jsp/header.jsp.md#watermark_datetime) 組成之兩行文字
- `image` [選填] - `contentType` 為 `"image"` 時之圖片來源；`header.jsp` 未傳入
- `width` [Number = `200`] - 單一浮水印圖塊寬度（像素）；`header.jsp` 傳入 `190`
- `height` [Number = `100`] - 單一浮水印圖塊高度（像素）；`header.jsp` 傳入 `85`
- `rotate` [Number = `30`] - 浮水印內容旋轉角度；`header.jsp` 傳入 `17`
- `layout` [String = `"default"`] - 浮水印排列方式，`"grid"` 為網格排列；`header.jsp` 傳入 `"grid"`（見 [gridLayoutOptions](#gridlayoutoptions)）
- `gridLayoutOptions` [Object，選填] - `layout` 為 `"grid"` 時之網格排列設定；`header.jsp` 傳入 `{ rows: 2, cols: 2, gap: [-18, -8], matrix: [[1, 0], [0, 1]] }`（見 [gridLayoutOptions](#gridlayoutoptions)）
- `auxiliaryLine` [Boolean = `false`] - 是否顯示輔助線；`header.jsp` 未傳入
- `translatePlacement` [String = `"middle"`] - 位移動畫之基準位置；`header.jsp` 未傳入
- `textType` [String = `"fill"`] - 文字繪製方式；`header.jsp` 未傳入
- `imageWidth` [Number = `0`] - `contentType` 為 `"image"` 時之寬度；`header.jsp` 未傳入
- `imageHeight` [Number = `0`] - `contentType` 為 `"image"` 時之高度；`header.jsp` 未傳入
- `lineHeight` [Number = `30`] - 多行文字之行高；`header.jsp` 傳入 `20`
- `zIndex` [Number = `2147483647`] - 浮水印圖層堆疊順序；`header.jsp` 未傳入
- `backgroundPosition` [String = `"0 0"`] - 浮水印圖塊背景起始位置；`header.jsp` 未傳入
- `backgroundRepeat` [String = `"repeat"`] - 浮水印圖塊背景重複方式；`header.jsp` 未傳入
- `fontSize` [String = `"20px"`] - 文字字級；`header.jsp` 傳入 `"16px"`
- `fontFamily` [String = `"sans-serif"`] - 文字字型；`header.jsp` 傳入 `"Microsoft JhengHei"`
- `fontStyle` [String = `""`] - 文字樣式；`header.jsp` 未傳入
- `fontVariant` [String = `""`] - 文字變化樣式；`header.jsp` 未傳入
- `fontColor` [String = `"#000"`] - 文字顏色；`header.jsp` 傳入 `"#000"`
- `fontWeight` [String = `"normal"`] - 文字粗細；`header.jsp` 傳入 `"normal"`
- `filter` [String = `"none"`] - 圖塊濾鏡效果；`header.jsp` 未傳入
- `letterSpacing` [String = `"0px"`] - 字元間距；`header.jsp` 未傳入
- `wordSpacing` [String = `"0px"`] - 文字間距；`header.jsp` 未傳入
- `globalAlpha` [Number = `0.1`] - 浮水印透明度；`header.jsp` 傳入 `0.07`
- `mode` [String = `"default"`] - 浮水印模式；`header.jsp` 未傳入
- `mutationObserve` [Boolean = `true`] - 是否持續監控畫面內容，於浮水印遭移除或覆蓋時嘗試重新顯示；`header.jsp` 傳入 `true`
- `monitorProtection` [Boolean = `false`] - 是否鎖定瀏覽器提供予前項監控機制所需之全域能力，避免遭覆寫停用；`header.jsp` 傳入 `true`
- `movable` [Boolean = `false`] - 浮水印圖塊是否套用位移動畫；`header.jsp` 未傳入
- `parent` [String = `"body"`] - 浮水印掛載之容器；`header.jsp` 未傳入
- `onSuccess` [Function = `function(){}`] - 建立成功後回呼；`header.jsp` 未傳入
- `onBeforeDestroy` [Function = `function(){}`] - 銷毀前回呼；`header.jsp` 未傳入
- `onDestroyed` [Function = `function(){}`] - 銷毀後回呼；`header.jsp` 未傳入
- `onObserveError` [Function = `function(){}`] - 前項監控機制發生錯誤時回呼；`header.jsp` 未傳入
**輸出**:
- `return`: [WatermarkPlus.Watermark 實例] - 供後續呼叫 [create()](#create)
**輸出條件**: 預設輸出

## gridLayoutOptions
**使用情境**: `layout` 為 `"grid"` 時之網格排列設定，為 [WatermarkPlus.Watermark(options)](#watermarkpluswatermarkoptions) 之子選項
**使用方式**: `"gridLayoutOptions" : { rows, cols, matrix, gap, width, height, backgroundImage }`
**主要功能**:
- 決定浮水印圖塊於網格中之列數、欄數、各位置是否顯示，以及格與格間距
**輸入**:
- `rows` [Number = `1`] - 網格列數；`header.jsp` 傳入 `2`
- `cols` [Number = `1`] - 網格欄數；`header.jsp` 傳入 `2`
- `matrix` [Array&lt;Array&lt;Number&gt;&gt; = 全數為 `1` 之 `rows` × `cols` 矩陣] - 各網格位置是否顯示浮水印圖塊（`1` 顯示、其餘不顯示）；`header.jsp` 傳入 `[[1, 0], [0, 1]]`
- `gap` [Array&lt;Number&gt; = `[0, 0]`] - 網格間距 `[水平, 垂直]`；`header.jsp` 傳入 `[-18, -8]`
- `width` [Number，選填] - 整體網格畫布寬度；`header.jsp` 未傳入
- `height` [Number，選填] - 整體網格畫布高度；`header.jsp` 未傳入
- `backgroundImage` [Image，選填] - 網格背景圖像；`header.jsp` 未傳入
**輸出**: 無
**輸出條件**: 預設輸出

## create()
**使用情境**: 顯示已建構之個人化浮水印
**使用方式**: `watermarkInstance.create()`
**主要功能**:
- 依建構選項繪製浮水印圖塊，並以其鋪滿所屬容器範圍後顯示於頁面上，顯示效果不影響容器內原有內容之滑鼠操作
- `mutationObserve` 為 `true` 時，持續監控畫面內容，於浮水印遭移除或覆蓋時嘗試重新顯示
**輸入**: 無
**輸出**:
- `return`: [Promise] - 顯示流程完成後解決，不攜帶回傳值
**輸出條件**:
- 呼叫當下已有一次建立流程進行中時，本次呼叫略過，不重複執行
- 所屬容器內尚無既有浮水印，且顯示內容有效（`contentType` 為文字類型時 `content` 須為非空字串；為 `"image"` 時須提供 `image` 選項）時，才會實際繪製並顯示；不符合任一條件時略過，不顯示亦不觸發錯誤
