# DS_ImageUtil.js 公開契約

> 原始資源：`/DS/js/DS_ImageUtil.js`

## **`ImageUtil.showImage(options)`**

### 用途

- 透過 DS 影像頁面，在指定容器中建立或更新具狀態條件的影像。

### 輸入

- `options`: [Object] - 影像來源與呈現設定；原始實作未提供空值保護。
  - `options.imagePath`: [String] - 送往 `DS_ShowImage.jsp` 的影像路徑；以 `encodeURI` 編碼後放入 `IMAGE_PATH` 查詢參數。
  - `options.status`: [Any = undefined] - 原樣轉成 `STATUS` 查詢參數的影像狀態。
  - `options.showImageDivId`: [String] - 必填。承載影像的容器 `id`，同時用來組成影像元素識別 `_ImageUtilImageName_{showImageDivId}`。
  - `options.imageWidth`: [Number|String = 100] - 影像 `width` 屬性；任何 falsy 值均改用 `100`。
  - `options.imageHeight`: [Number|String = 100] - 影像 `height` 屬性；任何 falsy 值均改用 `100`。
  - `options.imageVspace`: [Number|String = 0] - 影像垂直留白 `vspace`。
  - `options.imageHspace`: [Number|String = 0] - 影像水平留白 `hspace`。
  - `options.align`: [String = undefined] - 影像 `align`；未提供時移除既有屬性。
  - `options.imageAlt`: [String = undefined] - 影像替代文字 `alt`；未提供時移除既有屬性。

### 輸出

- `return`: [undefined] - 此操作不回傳影像元素。

### 對外功能

- 依第一個樣式表網址推導系統根路徑，將 `IMAGE_PATH` 與 `STATUS` 交由 `html/DS/DS_ShowImage.jsp` 提供內容。
- 先設定顯示影像的 `src`，並以另一個記憶體影像等待載入完成後再套用尺寸與呈現屬性。

### 副作用

- 建立或改寫全域 `ImageUtil`，因此會取代先前載入的同名工具。
- 新增或更新容器內的影像元素，且同一網址可能同時被顯示元素與預載元素請求。
- 影像載入失敗時沒有錯誤回呼，尺寸、留白、對齊與替代文字可能維持舊值或尚未設定。
- 找不到指定容器且影像尚未存在時，`appendChild` 會拋出例外。
