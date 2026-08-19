# ImageUtil.js 公開契約

## 使用語法清單
**方法**:
- [ImageUtil.showImage(options)](#ImageUtil.showImage(options))

---

## ImageUtil.showImage(options)
**使用範例**:
```
ImageUtil.showImage({
    imagePath : filePath,
    showImageDivId : 'image',
    imageWidth : '700px',
    imageHeight : '100%'
});
```
**輸入**:
- options: object - 顯示圖片所需參數集合
- options.imagePath: string - 圖片存放路徑
- options.showImageDivId: string - 顯示圖片之容器識別碼
- options.imageWidth: string | number = 100 - 圖片寬度
- options.imageHeight: string | number = 100 - 圖片高度
- options.imageVspace: string | number = 0 - 圖片上下留白間距
- options.imageHspace: string | number = 0 - 圖片左右留白間距
- options.align: string = 無 - 圖片對齊方式
- options.imageAlt: string = 無 - 滑鼠移至圖片上顯示之提示文字
**輸出**: 無
**功能**:
- 於指定容器內插入或更新圖片元素
- 依傳入路徑組成圖片來源位址，並套用尺寸、間距、對齊、提示文字等顯示屬性
- **當 options.imageAlt 未提供時**: 移除既有提示文字屬性
- **當 options.align 未提供時**: 移除既有對齊屬性
