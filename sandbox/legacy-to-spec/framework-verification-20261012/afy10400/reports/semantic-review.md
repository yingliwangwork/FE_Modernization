# AF-AFY10400 維護續作語意復核

**原 F-01..08 的修正已成立；凍結文件仍有兩項確證殘餘問題。** 本輪維持部分沙盒成果，不宣稱正式 AF 完成。18項一般瀏覽器檢查及2項生命週期檢查均 PASS，只能證明本輪明列的本地原型範圍。

審查日期：2026-10-12。Run：`framework-verification-20261012`。唯一入口：`inputs/frontend/sourceCode/AF/AFY10400.jsp`，scope `AF-AFY10400`。這是有已知審查資訊的維護復核，**不是盲審**。

## 範圍與基準

讀取本 case 的 task、manifest、skill、原始 inputs、本 case 內提供的前輪快照與審查文件、artifacts；當次外部驗證結果只讀 [browser.json](browser.json) 與 [lifecycle-browser.json](lifecycle-browser.json)。本輪未讀 scenario、checks 腳本、其他 case 或外部資源，未修改任何產物；只寫本報告。先核對定稿 runtime，收到文檔凍結通知後才作最終文件判定。

依新版 skill R1–R9 與本 case 的 evidence、dependencies、JSP、UI/style 規則回查原始來源。審查內容只引導查證，不作產品行為權威。後端基準仍是 `inputs/backend/docs/OPENAPI.md`；方法規格仍只提供 legacy 業務語意。

獨立重算 manifest 中可讀的71檔 SHA-256，無不符；依讀取限制排除6個 checks 腳本，沒有宣稱自行重算全部77檔。根 JSP 與指定後端基準原始 hash 未變。兩份當次瀏覽器結果的 HTML／JS／CSS hashes 與定稿 runtime 相符：一般報告6檔、生命週期報告8檔。一般報告中的 DESIGN hashes 是整理中文件版本，沒有用它們證明最終 DESIGN 已驗證。

## F-01..08 逐項判定

| Finding | 原始依據與實際修正 | 本輪證據與判定 | 保留限制 |
| --- | --- | --- | --- |
| F-01：審閱區遮擋確認 | `review.css` L2改為200；位於遮罩150以上、訊息999以下，沒有改來源訊息定位公式 | 正常點擊確認、重開與拖曳的 browser 結果 PASS。**原問題已修正** | 沒有測遍所有視窗尺寸及任意工具內容幾何 |
| F-02：外置訊息失去全域樣式 | cm.css L12–15、L542–545；FORM CSS L2/L16將字型及 readonly 規則補到 `#message` 的產品控制 | readonly border 與 padding 的 browser 檢查 PASS；STYLE-FORM-01/36/37明列外置 UI-10。**原問題已修正** | 實際字型可用性與缺少後載樣式仍 TODO-05 |
| F-03：結果格被置中 | 根 L40–58只將前三格置中；新版動態前三格加 center-cell，CSS L8只命中標籤／標題／這三格 | 結果格 start 的 browser 檢查 PASS；FORM STYLE-13明列排除 UI-08。**原樣式問題已修正** | 正式 UI-08 的 E 引用仍有 DOC-01；這不否定已通過的 runtime 結果 |
| F-04：遮罩焦點嘗試漏項 | CSR L321–326；prototype L8新增按當時 active control type 包含 button 才嘗試聚焦，失敗保留診斷；送出、訊息顯示及無活動關閉取得遮罩有去向 | E-26、CMP-COVER／FLOW-06／AC-19已補；lifecycle 觀察 activeType=button、attempts=1 PASS。**已知觸發／嘗試已補回** | 只證明呼叫嘗試，不能證明 OS 改變可見焦點；AC-19所有負向／例外條件沒有都由該報告實測 |
| F-05：正式契約依賴來源符號 | spec/common改用資料、事件、呈現能力及模式 A/B；Prototype／jQuery／WIUtil／PageUI與條件辨識搬到 tracking §9.2，wire留API | A/B順序、原生／自訂／成功僅收遮罩子情境、首鍵與全頁作用範圍仍保留；没有因中立化省略分支。**原問題已修正** | DOC-02 的共用契約版本標示尚未一致；來源／部署選用情境仍未知 |
| F-06：STYLE證據與token映射 | PAGE STYLE-26引用E-03根191/193；STYLE-27..29引用E-07 header101–112；所有STYLE給實際token路徑或明確無token正文規則、來源定位及CSS | 128項宣告對到實載CSS；28筆token使用（含1筆跨元件引用）可解析並與CSS等價。**原STYLE問題已修正** | 沒有把靜態映射或metadata PASS當成128項 computed style全通過；其他正式UI引用見DOC-01 |
| F-07：DEP表欄位錯位 | plan L24–40改為DEP及資源分開的7欄，15列一致；位置表移除截斷Markdown片段 | 獨立核對44份Markdown表格的欄位數，無不符；367筆局部位置回读無缺少完整TODO連結。**原問題已修正** | 單行連結／欄位檢查不是完整GFM renderer；位置存在不等於未知依賴已全盤點 |
| F-08：拖曳中首鍵額外阻斷 | CSR L1545–1555、L1613–1625；prototype首鍵先解除自身，再要求視窗仍有parentNode才確認／阻斷 | E-27、FLOW-09/10、AC-20同步；lifecycle觀察 accepted=true、defaultPrevented=false、propagated=1 PASS。**原問題已修正** | 使用合成keypress，不證明原生Escape跨瀏覽器相容性 |

## ●與缺失圖片的來源核對

根 JSP 原始 L143 是20×24的格，L144明確寫有 `<div align="center"><font size="-5">●</font></div>`。●是原始文字，具有直接 E-02 依據；**保留它沒有補造圖片**。新版 HTML L9保留此文字、置中與原字級條件，PAGE DESIGN 的 STYLE-PAGE-DOT另有說明。父代理先前提出移除後已回查撤回，tracking與TASK-13保留此更正，沒有轉成產品變更授權。

L132–155的4×12、12×4、5×1及L179的18×16圖像位置只保留空槽幾何。原型未加入未知圖像URL，沒有宣稱缺失圖片、背景平鋪或真實字型已還原，TODO-05仍成立。

## 凍結後仍存在的確證文件問題

### DOC-01／中：UI-08 的新增對齊主張未引用支持它的 E

位置：[specification.md](../artifacts/design/AF-AFY10400/specification.md) L55；[tracking.md](../artifacts/renovation/AF-AFY10400/tracking.md) E-05。

UI-08明確要求起始對齊，前三格置中不適用結果格，但該列只引 E-05。E-05仍登錄根 L98–114的結果回填／下載，沒有根 L40–58的新增格對齊。實際支持此主張的 E-01 沒有出現在該正式 UI 列；FORM STYLE-13已有正確 E-01/E-03，故問題是文件追溯鏈不一致，runtime已正確。

需將UI-08的對齊主張連到E-01及適用的STYLE映射，保留E-05支持回填。已知來源可以直接定位，不應把此錯位歸因於外部未知。

### DOC-02／低：根規格仍指定共用契約 v1

位置：[specification.md](../artifacts/design/AF-AFY10400/specification.md) L59。

該段稱共用 CMP-ENTRY/REQUEST/POLICY/DOWNLOAD為「版本v1」，但實際連結 [common-contracts.md](../artifacts/design/AF-AFY10400/common-contracts.md) 標題與內容是v2，BR-06及FLOW-06亦引用v2。已鎖定的重用版本自相矛盾，特別影響新增聚焦／首鍵guard與中立模式定義的維護辨識。

需更新當前消費版本；前輪v1仍留在inputs快照作歷史，不應讓當前連結同時宣稱v1及v2。本輪不等待修補，保留此文件問題。

## 局部位置、權威與驗證範圍

獨立解析四份最終 DESIGN：PAGE44＋FORM40＋COVER10＋MESSAGE34，共128项。逐列回查selector／property／值與實載CSS；28筆token使用的值一致（27筆直接frontmatter、1筆跨CMP引用）。色彩短式與長式按CSS等價處理，沒有把 `#fff`／`#FFFFFF` 的寫法差異當成缺陷。SOURCE定位與條件仍需語意核對，不能由宣告存在自動推論來源權威成立。

tracking §5.1的367筆位置逐列回讀：所指文件、實際行號及該行完整 `TODO-ID` 錨點連結均存在，沒有沿用前輪截斷引用。DATA-03..08、相關BOUND/UI/FLOW、狀態條件、共同CMP及STYLE都有去向，缺少全域樣式／載入副作用由CMP-PAGE明示传播。位置表也明載同列出現的ID不能當成完整影響閉包。此核對證明**列出的實際位置與引用**；沒有宣稱每項未知依賴內部已盤點完成。

API与handoff相對本case前輪快照未改寫。指定後端基準仍保留POST、平行陣列、精確envelope／HTTP200業務錯誤、binary下載及stub性質；prompt未強加為本頁產品事件。拒絕逐列結果、舊加密鏈與目標直接檔案、可信設定／身分／時間、複製與匯出稽核、查詢／54欄Excel等責任仍保留HANDOFF與TODO。沒有由本地原型補造後端計算、正式部署或寫入成功。

初輪plan時間、V-01..07、失敗及输入快照留存；第9節另列續作E-26..29、V-08..11與版本修正，没有把初輪FAIL改寫為PASS。最終document-check 4589項及四份metadata報告PASS已讀取，其宣告範圍只作補充；本審查未讀或執行其checks腳本，DOC-01/02也說明該PASS不能代替語意／版本核對。

兩份允許的當次瀏覽器報告皆無runtime errors與network attempts。一般18項包括初始化、增刪、檢核順序、目前ID回填、拒絕、訊息文案與累積、拖曳／重開、政策、獨立到期、按鈕cascade及結果對齊；額外2項檢查聚焦嘗試及detached首鍵guard。它們不是所有AC、所有STYLE、所有分支或所有視窗尺寸的全面驗證。

未取得legacy執行畫面、正確date解碼、外部訊息／底部／可信提供方、圖片／字型／calendar CSS／浮水印庫、正式服務与授權／檔案／稽核環境。TODO-01..07仍開啟；本地瀏覽器PASS不能關閉這些缺口，也不能證明像素等價、OS焦點、原生Escape相容性、真實60秒牆鐘計時或正式介接。本審查以結果報告驗證其明列範圍，沒有另行執行瀏覽器。

最終判定：**修正後的部分沙盒成果**。原8項審查事項有修正與適用證據，仍有DOC-01/02文件偏差及既有未知邊界；不標為正式AF完成。
