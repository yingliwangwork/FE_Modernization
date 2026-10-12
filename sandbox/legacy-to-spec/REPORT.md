# Legacy-to-spec 沙盒測試紀錄

測試日期：2026-10-12。生成代理讀取各輪 skill 與原始材料快照實際產出文件；來源審查與瀏覽器驗證分別進行。manifest 保留輸入與受測 skill 的 SHA-256。原始 JSP 與後端工具未修改，各輪只代表其受測版本與範圍。

## 已完成的行為驗證

| 案例 | 結構與輸入完整性 | 真實瀏覽器案例 | 獨立來源審查 |
| --- | --- | --- | --- |
| [修補後耦合案例](verification/coupled/artifacts/design/fixture-case/specification.md) | [37 份快照、764 連結通過](verification/coupled/reports/structure.json) | [8/8 通過](verification/coupled/reports/browser.json) | [C-01–03 已解，未發現新重大缺陷](verification/coupled/reports/semantic-review.md) |
| [修補後 AFY10400](verification/afy10400/artifacts/design/AF-AFY10400/specification.md) | [49 份快照、167 連結通過](verification/afy10400/reports/structure.json) | [20/20 通過](verification/afy10400/reports/browser.json) | [原六項及 handler 身分缺陷已解](verification/afy10400/reports/semantic-review.md) |
| [待決規劃續作](pending-continuation/coupled/artifacts/renovation/fixture-case/plan.md) | 規劃階段，未執行全交付 checker | 不適用 | [本階段無待修缺陷](pending-continuation/coupled/reports/semantic-review.md) |

`verification/` 是有先前審查意見的維護回合，不能視為盲測生成成功率。待決規劃只交付 plan／tracking／[資源影響告知](pending-continuation/coupled/reports/dialogue.md)，使用者沒有回答，故依賴決策維持待決，未生成相依設計；不因缺少 prototype 判為失敗。

28 項已完成的本地瀏覽器案例涵蓋查閱清除與保留順序、識別請求逆序回填、數量空字串、增刪列、選項、零列與重複值驗證順序、接受／拒絕及下載邊界、全頁鍵盤政策、拖曳中間態、獨立複製計時器、空訊息及累積寬度、處理例外先於完成、CSS cascade、非同步底欄回應，以及滑鼠確認後重開的 listener 身分。瀏覽器使用新 context、合成資料，HTTP 全阻擋；兩份最終報告皆無 page／console errors 或 HTTP attempts。Escape 回歸使用合成 keypress，只證明已知條件與 handler 生命週期，未證明原生 Escape 的跨瀏覽器相容性。

## 各輪保留結果

| 輪次 | 耦合案例 | AFY10400 | 主要發現／後續 |
| --- | --- | --- | --- |
| baseline，盲測 | [結構通過](baseline/coupled/reports/structure.json)、[6/6 browser](baseline/coupled/reports/browser.json) | [結構通過](baseline/afy10400/reports/structure.json)、[7/7 browser](baseline/afy10400/reports/browser.json) | [可取得性誤寫部署狀態](baseline/coupled/reports/semantic-review.md)；[共用非同步原生回饋遺漏](baseline/afy10400/reports/semantic-review.md) |
| regression，盲測 | [結構通過](regression/coupled/reports/structure.json)、[7/7 browser](regression/coupled/reports/browser.json) | [結構通過](regression/afy10400/reports/structure.json)、[9/12 browser](regression/afy10400/reports/browser.json) | [事件範圍、拖曳、獨立計時器差異](regression/afy10400/reports/semantic-review.md) |
| refinement，盲測新依賴流程 | [結構通過](refinement/coupled/reports/structure.json)、[7/7 browser](refinement/coupled/reports/browser.json) | [結構通過](refinement/afy10400/reports/structure.json)、[12/12 browser](refinement/afy10400/reports/browser.json) | [局部 TODO／案例引用缺漏](refinement/coupled/reports/semantic-review.md)；[metadata、例外分支、訊息樣式／尺寸、CSS、TODO、中立術語六項](refinement/afy10400/reports/semantic-review.md) |
| continuation，依新版 skill 續作，無審查答案 | [結構通過](continuation/coupled/reports/structure.json)、[7/7 browser](continuation/coupled/reports/browser.json) | 未執行 | [影響盤點、請求識別定義、表格斷行三項](continuation/coupled/reports/semantic-review.md) |
| pending-decision，規劃／對話試驗 | [來源審查](pending-decision/coupled/reports/semantic-review.md) | 未執行 | 告知群組遺漏認證／其他回應影響，後於 pending-continuation 修正 |
| verification，審查引導維護 | 來源、結構、browser 8/8 通過 | 來源修補、結構、browser 20/20 通過 | 詳見上表，外部缺口保持開啟 |

舊產物與失敗報告保留，沒有改寫使歷史測試變綠。依賴政策 `defer`／`convert-available` 是沙盒明示模擬決策；沒有取得正式專案擴張或延後的授權。

## Skill 修正依據

| 可重現發現 | 正式 skill／工具修正 |
| --- | --- |
| 未提供呼叫環境被推論為未部署 | 可取得性與部署狀態分開，沒有依據則未知 |
| 條件式回饋、全頁事件、手勢中間態、計時器或 listener 身分丟失 | 保留作用範圍、各分支、生命週期與交錯順序；驗收不只比較終畫面 |
| 把根入口編碼／行數套在依賴，或 replacement decoding 當成功 | 逐檔原始 bytes、hash、物理行與 strict codec 核對；成功解碼不證明預期編碼 |
| TODO 只在總索引存在、影響範圍漏資料／狀態、API 引用案例不涵蓋所稱內容 | 逐位置核對、依來源盤點全部影響、案例跨引用回讀；未知仍維持部分交付 |
| 最小 DOM microtask 模型通過但原生 click 清掉底欄回應 | 保留真實 button 政策，讓人工回應在事件傳播後交付；原生瀏覽器另驗，不以 mock 代替 |
| 人工審閱層遮住訊息窗確認按鈕 | 只調整審閱層，保留來源產品層級；用原生滑鼠操作確認，不 force-click |

AF 的 [18/19 回應順序失敗](verification/afy10400/reports/browser-before-event-fix.json)、[未等待非同步的驅動檢查](verification/afy10400/reports/browser-before-async-waits.json)、[19/20 遮擋失敗](verification/afy10400/reports/browser-before-review-layer-fix.json) 均保留。最終 suite 對非同步交付明列有界等待，再核對具體結果；同步順序案例沒有放寬。產品原型 hash 與報告相符。

## 樣式與客製化

新增試驗使用 `styles/coupled` 的獨立快照，測試客製 DESIGN.md、API explicit override、其他角色 fallback、補充 API 撰寫規則，以及 DESIGN.md／CSS／DTCG tokens 交付。只提供既有來源樣式，未批准新產品設計。

| 核對 | 原始盲測 styles/coupled | 審查引導續作 styles-verification/coupled |
| --- | --- | --- |
| 實際交付 | 三份元件 DESIGN.md／CSS，11 項來源宣告、8 個尺寸／色彩 tokens；[prototype](styles/coupled/artifacts/design/fixture-case/prototypes/SCR-01.html) | [修正後元件樣式文件](styles-verification/coupled/artifacts/design/fixture-case/components/CMP-PAGE/DESIGN.md)，CSS／HTML／JS／tokens byte-identical |
| 結構與输入 | [36 快照、148 連結通過](styles/coupled/reports/structure.json) | [64 快照、154 連結通過](styles-verification/coupled/reports/structure.json) |
| 本地顯示 | [5/5 Chromium 情境、22 斷言通過](styles/coupled/reports/browser.json)，含動態資料列 CSS；0 errors／HTTP attempts | [沿用實際觀察的 byte-identity 證據](styles-verification/coupled/reports/inherited-browser-check.json)，不是瀏覽器重跑 |
| 格式 | [Typography 字串形狀錯誤已重現](styles/coupled/reports/design-metadata-before-fix.json)；[主代理格式審查](styles/coupled/reports/format-review.md) | [三份元件 metadata 形狀檢查通過](styles-verification/coupled/reports/design-metadata.json)；非完整官方 validator |
| 來源／客製審查 | [樣式值與 API 權威正確；行號範圍低嚴重度缺陷](styles/coupled/reports/style-semantic-review.md)。中途讀取引發的 DATA prefix 誤報已撤回 | [獨立復核：F-01／FORMAT-01 已解，本範圍無剩餘缺陷](styles-verification/coupled/reports/style-semantic-review.md)；保留原模板及格式失敗 |

新增可重現 FORMAT-01 的修正已納入維護 UI 規則：typography 的每個 token 必須是物件，使用 fontFamily 等欄位，不能直接置入 CSS 宣告。新增局部 metadata 檢查與三項測試；只補既有字型，沒有發明缺少的字級／行高。tokens 是明列範圍的選定輸出，百分比及複合規則保留在文件／CSS，不宣稱完整 token 化。引用末行亦要求核對原始物理行。

維護套件的模板已統一至 `templates/`，實際成果另存；API／UI／legacy 規則在分類 references，通用程序在 guides。舊輪快照維持原結構，不能把新樣式要求追溯算成舊輪已驗證項目。

## 工具與限制

- [沙盒工具](../../scripts/skill-sandbox.py)、[瀏覽器工具](../../scripts/skill-sandbox-browser.mjs) 與 [操作說明](../../tests/legacy-to-spec/README.md)。24 項工具測試通過：12 項 sandbox integrity／scope／plan／CSS-token 佔位符、3 項 source inventory、6 項範本選用／雜湊／錯誤設定、3 項 DESIGN metadata 形狀。
- 維護 skill 的 formatter 驗證與本地引用連結核對通過；這不證明模型每次生成都正確。每輪 manifest 是實際受測版本，後續用字修正另屬維護套件。
- 截圖見 [耦合案例](../../output/playwright/skill-sandbox/verification/coupled/items.html.png) 與 [AFY10400](../../output/playwright/skill-sandbox/verification/afy10400/SCR-01.html.png)。
- 所有翻新案例仍為部分交付：後端承接、認證、宿主與未提供依賴、正式服務、legacy 畫面比對等缺口沒有因本地測試通過而消失。沒有執行 JSP 服務端或真實 API，也不宣告像素等價、資料持久性或正式介接完成。
