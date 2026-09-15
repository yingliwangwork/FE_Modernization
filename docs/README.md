# 中間產物（SoT）研究記錄

## 目錄結構

```
docs/
  v1/                   第一輪：最少提示詞基線
    README.md           本輪記錄與決策
    samples.md          基準樣本（固定不變）
    prompt-v1.md        本輪使用的提示詞
    sot/                三份 v1 SoT
    analysis.md         差異分析
  v2/                   第二輪投入物
    template.md         SoT 模板
    rules.md            撰寫規則
```

## 迭代狀態

| 輪次 | 狀態 | 遺漏項數 | 產出 |
|---|---|---|---|
| v1 | 已完成 | 33（8 類） | v2 模板 + 規則 |
| v2 | 未開始 | — | — |

## 基準樣本

見 `v1/samples.md`。一經確立即固定不變，往後各輪均使用同一組樣本。

| 層級 | 檔案 | 行數 |
|---|---|---|
| 低 | `sourceCode/DS/C8/DSC8_0100/DSC80106.jsp` | 240 |
| 中 | `sourceCode/DS/C3/DSC3_2200/DSC32200.jsp` | 383 |
| 高 | `sourceCode/AF/AFY10100.jsp` | 2012 |
