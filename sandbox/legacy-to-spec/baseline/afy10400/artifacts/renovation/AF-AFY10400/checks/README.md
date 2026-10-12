# 本輪檢查紀錄

2026-10-12，case 內本地 Node／Python，不使用套件安裝、外部資料或真實端點。

依序執行：

```sh
python3 artifacts/renovation/AF-AFY10400/checks/verify_static.py
node --check artifacts/renovation/AF-AFY10400/checks/prototype-script.js
node artifacts/renovation/AF-AFY10400/checks/check_interactions.js
```

- [input-inventory.json](input-inventory.json)：manifest 32 個 skill／input 檔 SHA-256 全部相符；唯一根 Big5／CRLF，246 行。date.js 嚴格 UTF-8／Big5／CP950／Big5HKSCS 都無法解碼，未以替換字元猜內容。
- [static-report.json](static-report.json)：本輪 Markdown links／TODO anchors、HTML root mapping、靜態／動態 UI/FLOW/CMP映射、模板、外連與常見 network API 掃描，無錯誤。HTMLParser 不等於完整瀏覽器驗證。
- JS 語法：`node --check` exit 0，無輸出；腳本由原型重新提取，見 [prototype-script.js](prototype-script.js)。
- [interaction-report.json](interaction-report.json)：十個有業務辨識力的本地最小 DOM 替身檢查，十通過／零失敗，環境與每項實際結果均列出。此替身沒有真實瀏覽器、CSS布局、原生 alert/maxlength/焦點/Enter/事件派送或下載能力。

未執行 browser／JSP／API／正式下載／legacy 像素比較。沒有截圖。條件保護、浮水印、外層框架訊息、內建 MsgWin 的部署選用、可信情境與目標 envelope/binary 只做來源／文件核對，不能由替身通過宣稱 runtime 等價。父層若執行本地瀏覽器檢查，應另記操作與結果，不能回寫成此輪已執行的觀察。
