# 固定專案設定與 JSP 定位

呼叫介面只有 `jsp=<路徑>`，亦接受單獨的 JSP 路徑。來源、SOT 及輸出位置由使用者事先編輯專案設定；不要每次詢問 workspace、output 或 sot 參數。

## 設定檔選擇

- 載入 `.agents/skills/jsp-to-spec/` 時，讀本次專案 `.agents/jsp-to-spec.yaml`。
- 載入 `.github/skills/jsp-to-spec/` 時，讀本次專案 `.github/jsp-to-spec.yaml`。
- 只缺本平台設定時，可讀另一平台同名設定；兩份都存在時以本次載入平台為準，不暗中合併。兩者可由使用者設定不同位置，不要求設定值同步。
- 兩份都不存在時，採內建預設：source_roots 為目前專案、sot_roots 為 `.agents/docs` 及 `.github/docs`、output_root 為 `.agents/docs`。不自行寫入設定檔。
- 已有設定語法錯誤或必要值不合法時，指出具體欄位，不以廣搜檔案或靜默預設代替修正。必要欄位為非空 source_roots 清單及 output_root 字串；sot_roots 可為空清單。

## 欄位與解析

```yaml
source_roots:
  - "."                     # 預設整個目前專案，可改成既有來源根目錄
sot_roots:
  - ".agents/docs"          # 使用者提供的 API／原始資料契約位置
  - ".github/docs"
output_root: ".agents/docs" # 所有轉換與參照產物的位置
```

相對路徑均以本次執行專案根目錄為基準，不相對於 skill／設定檔所在目錄；絕對路徑原樣解析。source_roots 與 sot_roots 的聯集為可查找業務來源範圍。source_roots 必須存在且可讀；sot_roots 未建立時記錄無外部 SOT，不阻止已知頁面分析。output_root 不得覆寫來源或 skill。

jsp 為絕對路徑時驗證其屬於設定來源；相對路徑先相對專案解析，再在 source_roots 中比對。多個不同檔案符合時，請使用者提供唯一 JSP 路徑，不擅選第一個。同一實際檔案經不同路徑命中只算一次。只提供檔名時，可在已盤點檔名中精確比對，不讀無關文件內容。

## 相關文件的主動查找

設定目錄不是 AI 只能讀某一份文件的限制。從目標 JSP 的引用、表單目的地、事件及原始欄位出發，可在設定來源內使用精確路徑、類別／函式名、路由或欄位名搜尋，讀取相關片段；必要時讀完整相關文件，以確認控制流程與契約。將依賴及證據納入盤點。

生成過的 spec／HTML 不自動成為權威 SOT；優先使用原始 JSP、實作證據及使用者提供的權威契約，衝突則並列證據與 SP。skill 的 examples／templates／references 不當成正式業務來源或 SOT，除非目標本身明確為該教學夾具。工具操作規範／skill 資源可正常讀取，不需為讀取工具規範再要求擴大業務範圍。
