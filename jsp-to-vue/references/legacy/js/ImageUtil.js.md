# ImageUtil.js 公開契約

> 原始資源：`/CM/js/ImageUtil.js`

## **`ImageUtil.showImage(options)`**

### 用途

- 透過共用影像頁面，在指定容器中建立或更新一張影像。

### 輸入

- `options`: [Object] - 影像來源與呈現設定；原始實作未提供空值保護。
  - `options.imagePath`: [String] - 送往共用影像頁面 `ShowImage.jsp` 的影像路徑；以 `encodeURI` 編碼後放入 `IMAGE_PATH` 查詢參數。
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

- 依第一個樣式表網址推導系統根路徑，將影像路徑交由 `html/CM/ShowImage.jsp` 提供內容。
- 容器內已有對應識別的影像時更新該元素，否則建立新的 `<img>`。

### 副作用

- 建立或改寫全域 `ImageUtil`，因此資源載入順序會決定同名工具的最終版本。
- 新增或更新容器內的影像元素及其 `src`、尺寸、留白、對齊與替代文字屬性，並觸發瀏覽器影像請求。
- 找不到 `options.showImageDivId` 指定的容器且影像尚未存在時，`appendChild` 會拋出例外。
