# fixture-case：翻新計劃與持續追蹤

> 系統契約見 [specification](../../design/fixture-case/specification.md)。本文件承載來源、TODO、實際驗證與進度；目前為部分交付。

## 1. 本輪來源與邊界

| 項目 | 內容 |
| --- | --- |
| Scope ID | fixture-case，由 manifest 指定；本案例交付前沒有既有 artifacts 或識別衝突 |
| 唯一根入口 JSP | inputs/frontend/Case.jsp |
| 根版本／雜湊 | SHA-256 90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154；與 manifest 相符 |
| 編碼／行號 | 原始 bytes 可嚴格解碼 UTF-8、LF；宣告 UTF-8；無轉碼或改寫；原件 1-based 行號（60 行） |
| 分析日期／執行者 | 2026-10-12／Codex；本次獨立提供的 snapshots |
| 納入 | 初次建立與提交後正常呈現、scriptlet 動作分支／解析／運算／保存、受信任來源、兩個輸入、查閱共用動作列、三欄表格、查閱三碼及其他碼、空量攔截、表單 hidden 動作、bridge 與 CSS、已提供的兩份後端契約 |
| 排除 | Ledger 實作、登入／session 建立、正式端點與環境、其他入口內部均未提供；不讀父專案、其他案例、測試或外部來源；不修改原始快照或 skill |
| 狀態／版本 | 部分交付 v1；三項責任未承接、身份／例外未知、瀏覽器和實際介接未執行 |
| 上一輪 | 首次，CHANGE-01 |
| 後端根／基準 | inputs/backend；使用 task 指定 api-contract.md fixture-v1，另讀相關 business-rules.md fixture-v1；雜湊見依賴表 |
| 後端性質／環境 | 沙盒測試交付契約、非正式服務、沒有可呼叫環境（E-10）；不是已部署或已實測 stub |
| 介接文件 | [API 消費規格](../../integration/fixture-case/api-spec.md)；[後端移交](../../integration/fixture-case/backend-handoff.md) |

### 依賴分析邊界

| 來源 | SHA-256／版本 | 目的 | 讀取／停止邊界 | 可取得性／結果 | 證據／TODO |
| --- | --- | --- | --- | --- | --- |
| inputs/frontend/components/action-bar.jspf | 61f70725865ae2fc7e49b2aea291e420255f4b1e5049728fc48740431871ff9e | 動作列與觸發 | 全 1 行，只分析根 JSP 的用法；不是第二入口 | 已讀 | E-08、CMP-01 |
| inputs/frontend/legacy-bridge.js | f008cb043d31d427d923e66ae33e1e98c13dd1dc9dd3f668c2fd3faf72eda09a | 交換協定及 callback | 全 8 行；停於 legacy 遠端 handler，不呼叫 | 已讀；没有 catch、timeout、cancel 來源 | E-14、TODO-05 |
| inputs/frontend/styles/base.css | 447252200c775df2b42ee0656df20334a806d91799a20602cc8f8b71d8debd99 | 樣式 | 全 4 行；沒有額外資源或圖片來源 | 已讀；只支撐來源樣式，不是執行畫面 | E-09、TODO-06 |
| inputs/backend/api-contract.md | 04215f381bc195b357b184c89d90e6f4fba521580feb7147c141a25cdb1ca802／fixture-v1 | task 指定的 wire 基準 | 全 27 行；只投影本頁的已確認操作 | 已讀 | E-10～E-12 |
| inputs/backend/business-rules.md | 35e4253d281cacc662c065ed690337ae8a71f04233df8289c065828aba7614b7／fixture-v1 | 單位授權及查閱業務 | 全 6 行；不推导 HTTP 或数量能力 | 已讀 | E-13 |
| example.Ledger（根 JSP import 指向） | 未提供，版本未知 | 保存呼叫的實際效果、異常、交易 | 停於根 JSP L8 呼叫，不搜尋案例外內容 | 缺失；不確認永久保存或原子性 | E-02、TODO-03 |
| legacy handler /legacy/searchRows | 未提供，版本未知 | 舊實際回應、錯誤及資料語意 | 舊 bridge 僅有送出與 JSON 解析；目標另有指定 fixture 契約 | 缺失；不查詢端點 | E-14、TODO-05 |
| 服務端 request/session／登入情境建立 | 未提供，版本未知 | 名稱與單位來源、缺失、身份驗證 | 停於根 JSP 的屬性讀取及後端文件明確需求 | 缺失；不把情境變為前端輸入 | E-01、E-02、E-10、TODO-01、TODO-04 |
| legacy 執行畫面／瀏覽器及後端執行环境 | 未提供 | 渲染與實際操作等價核對 | 沒有本輪實際觀察；不調用外部系統 | 未取得／未執行 | TODO-06 |

所有可取得輸入已核對 UTF-8、LF 及 manifest 雜湊（V-01）。skill 的參考中外部路徑只為方法背景，不查閱，未將其視為本案例來源。

## 2. 翻新計劃

| 工作 | 範圍／完成條件 | 依賴 | 狀態 | 交付／紀錄 |
| --- | --- | --- | --- | --- |
| WORK-01 | 源碼與依賴盤點；一根入口、版本、條件覆蓋 | task、manifest、供給 snapshots | 完成已取得範圍；缺失部分開 TODO | E-01～E-14、V-01 |
| WORK-02 | 中立規格、逐觸發流程、案例與共用元件 | WORK-01 | 完成部分契約 | specification.md v1 |
| WORK-03 | 後端投影及耦合移交；不造新端點 | WORK-01 | 完成文件；承接未完成 | API-01、HANDOFF-01～HANDOFF-03 |
| WORK-04 | 離線原型、標籤／狀態／流程 ID、已知互動 | WORK-02 | 原型檔已產生；瀏覽器未驗證 | SCR-01.html、V-02、V-03 |
| WORK-05 | 結構、連結、hash、API 靜態核對及 JS 語法檢查 | WORK-02～WORK-04 | 檢查結果見第 7 節 | V-01～V-04、verification.json |
| WORK-06 | 瀏覽器、原畫面及真實介接驗證 | 執行環境及缺口處理 | 未執行，不能以靜態核對替代 | V-05～V-07、TODO-06 |

## 3. 證據登錄

以下源碼定位使用本節第一項鎖定雜湊；「FE」指 inputs/frontend/，「BE」指 inputs/backend/。證據均為原始碼或提供文件，沒有運行觀察或人工批准。

| ID | 類型／定位 | 最小摘錄／事實 | 支撐範圍 | 限制 |
| --- | --- | --- | --- | --- |
| E-01 | 原始碼 FE/Case.jsp L1–4 | UTF-8 宣告；從 session 的 reviewerLabel 讀取文字 | DATA-01、FLOW-01、HANDOFF-01 | 缺會話來源、缺失及轉義契約 |
| E-02 | 原始碼 FE/Case.jsp L2、L5–9 | mode=commit 分支；Integer.parseInt(quantity)；quantity≥4 ? quantity×8 : quantity×10；Ledger.store(session unitId, quantity, charge) | DATA-02、DATA-07～09、BR-03、FLOW-04、HANDOFF-02 | 呼叫證實不等於永久寫入；Ledger 實作缺失；例外、原子性未知 |
| E-03 | 原始碼 FE/Case.jsp L19–23 | 查閱清空 status；filter.value.trim()；傳 search_word；回應才清空 rows | DATA-03、BR-01、FLOW-02、ST-02 | 未執行；無成功前清空列或禁用指令 |
| E-04 | 原始碼 FE/Case.jsp L23–36 | 回應清空 rows；DONE 逐列 itemKey/itemText/rankHint；NONE「沒有項目」；BLOCK「不允許查閱」；皆 textContent | FLOW-03、TR-03～06、MSG-01/02、UI-06～09、DATA-04/05 | 未知列型別／格式／無效資料；三種之外沒有完整處理 |
| E-05 | 原始碼 FE/Case.jsp L38–44 | quantity.value === ''→alert「數量不得為空」且 false；其餘 true | FLOW-04、BR-02、TR-07/08、MSG-03 | 不證明數量業務合法性；没有 trim 或焦點操作 |
| E-06 | 原始碼 FE/Case.jsp L11–53 | 標題「項目查閱」；CSS/script 依賴；審閱者、12 字關鍵字、include、空狀態、三欄與空 tbody | SCR-01、UI-01～09、CMP-01、ST-01、FLOW-01 | 最終渲染未觀察；來源不代表像素等價 |
| E-07 | 原始碼 FE/Case.jsp L54–58 | POST form 無 action；onsubmit 檢核；hidden mode=commit；數量文字輸入、「送出數量」 | UI-10/11、DATA-06/09、FLOW-04、BOUND-03 | 舊表單交接到同一根入口；無目標數量操作；不是另一翻新入口 |
| E-08 | 原始碼 FE/components/action-bar.jspf L1 | action-bar 中一個 type=button「查閱」，onclick=searchRows() | CMP-01、UI-04、FLOW-02 | 僅本頁用法，不推廣元件庫 |
| E-09 | 原始碼 FE/styles/base.css L1–4 | sans-serif、max-width720、margin24、#222；表格合框寬100%，上下16，格框1px #555、padding6、左對齊；動作列上8 | SCR-01 視覺與 CMP-01 | 瀏覽器 default 樣式未知；沒有品牌或 breakpoint 證據 |
| E-10 | 文件 BE/api-contract.md L3、L7–12 | fixture-v1 測試交付、無環境；searchItems POST /v2/items/search；JSON；queryText 選填 string max12；空／省略不限、null 非法；單位服務端提供、不接受 client unitId；認證未定義 | API-01、DATA-02/03、BR-04 | 非正式或已部署能力；認證缺口 |
| E-11 | 文件 BE/api-contract.md L14–19 | 200 body object，必有 outcome string、rows array；OK/EMPTY/DENIED；列必有 rowId/label string；EMPTY/DENIED rows=[] | API-01 結果／資料、TR-03～05 | 無其他結果或非200；沒有 rankHint；OK 列數下限未明定 |
| E-12 | 文件 BE/api-contract.md L21–27 | searchRows 承接；search_word→queryText，trim保留；DONE/NONE/BLOCK→OK/EMPTY/DENIED；itemList→rows、itemKey→rowId、itemText→label；未承接 rankHint、名稱初始化、數量 | API 雙向映射及 HANDOFF-01～03 | 不補三項未承接能力 |
| E-13 | 文件 BE/business-rules.md L3–6 | fixture-v1 只查閱；依服務端單位判斷權限→DENIED／EMPTY／OK；排序、分頁、重送、取消、交易、數量計費與保存未定義 | BR-04、API-01 責任與性質 | 未定義不等於不需要；不能推論數量授權或計算 |
| E-14 | 原始碼 FE/legacy-bridge.js L1–8 | fetch('/legacy/searchRows') POST Content-Type JSON，JSON.stringify(parameters)→response.json()→receive；無catch／取消／逾時 | legacy BOUND-02 交接、TODO-05 | 不是目標操作的 HTTP 權威；不執行或反推 target fallback |

## 4. 來源到契約覆蓋

| 項目／定位 | 類型 | 證據 | 規格去向 | 原型去向 | 案例 | 結論 |
| --- | --- | --- | --- | --- | --- | --- |
| Case.jsp L1–2 | 編碼、Ledger import | E-01、E-02 | DATA-01、BOUND-03 | 非可見；meta UTF-8 | AC-01、AC-09 | 版本已鎖定；Ledger TODO-03 |
| Case.jsp L4 reviewerLabel | 受信任初始化 | E-01 | DATA-01、FLOW-01、BOUND-01 | UI-02 合成顯示值 | AC-01 | HANDOFF-01、TODO-01 |
| Case.jsp L5 mode guard | 隱含業務動作 | E-02 | DATA-09、FLOW-04、TR-08 | 表單 hidden 動作，不可見 UI | AC-08、AC-09 | HANDOFF-02、TODO-03 |
| Case.jsp L6 parse | 業務解析 | E-02 | DATA-07、FLOW-04 | 不在前端重製 | AC-08、AC-09 | HANDOFF-02、TODO-03 |
| Case.jsp L7 threshold >=4 | 業務分支 | E-02 | BR-03、DATA-08 | 不在前端運算 | AC-09 | HANDOFF-02、TODO-03 |
| Case.jsp L7 threshold <4 | 業務分支 | E-02 | BR-03、DATA-08 | 不在前端運算 | AC-09 | HANDOFF-02、TODO-03 |
| Case.jsp L8 session unitId／store | 情境與保存副作用 | E-02 | DATA-02、BOUND-03、FLOW-04 | 邊界記錄，不保存 | AC-09 | HANDOFF-02；TODO-03／04 |
| Case.jsp L9→11–60 | 正常返回後渲染順序 | E-02、E-06、E-07 | FLOW-01、FLOW-04、TR-01/08 | 不模擬業務成功；初始畫面可重設 | AC-01、AC-09 | 已知順序映射，目標提交後未知 |
| Case.jsp L15、48 | 文檔／可見標題 | E-06 | UI-01、SCR-01 | title、UI-01 | AC-01、AC-13 | 已映射 |
| Case.jsp L16–17 | style、bridge 依賴 | E-06、E-09、E-14 | SCR-01、BOUND-02 | CSS 內嵌；不引入真實bridge | AC-13 | 樣式映射；傳輸未執行 |
| Case.jsp L49 | 審閱者文字 | E-01、E-06 | UI-02、DATA-01 | UI-02 | AC-01 | 名稱來源 HANDOFF-01 |
| Case.jsp L50 | 關鍵字／max12 | E-06 | UI-03、DATA-03 | UI-03 maxlength12 | AC-02、AC-10、AC-12 | 已映射 |
| Case.jsp L51、jspf L1 | include 動作列 | E-06、E-08 | CMP-01、UI-04、FLOW-02 | data-component-id CMP-01／UI-04 | AC-02、AC-12、AC-13 | 單頁共用用法已映射 |
| Case.jsp L52–53 | 狀態段落／三欄／空列 | E-06 | UI-05～09、ST-01 | UI-05～09 | AC-01、AC-13 | 已映射 |
| Case.jsp L19–21 | 查閱事件、狀態清除、trim、送出 | E-03 | FLOW-02、TR-02、BR-01、BOUND-02 | ST-02；審閱層顯示送出值 | AC-02、AC-10、AC-12 | 已映射 API-01；認證 TODO-04 |
| bridge L2–6 | POST／JSON／回應 callback | E-14、E-10、E-12 | BOUND-02、FLOW-02/03；target 定義獨立 | 不使用 fetch；工具交付合成回應 | AC-10、AC-11 | 已投影；無真實介接 |
| Case.jsp L23 | 收到回應先清空列 | E-04 | FLOW-03 步驟1 | UI-09 清空 | AC-03～AC-06 | 已映射 |
| Case.jsp L24–30 | DONE、三欄、回傳順序、純文字 | E-04、E-11、E-12 | TR-03、ST-03、DATA-04/05、UI-06～09 | DONE legacy fixture；ST-03 | AC-03、AC-11 | 前兩欄映射；HANDOFF-03／TODO-02 |
| Case.jsp L31–32 | NONE 分支／文案 | E-04、E-12 | TR-04、ST-04、MSG-01 | ST-04／UI-05 | AC-04 | 已映射 |
| Case.jsp L33–34 | BLOCK 分支／文案 | E-04、E-12 | TR-05、ST-05、MSG-02 | ST-05／UI-05 | AC-05 | 已映射 |
| Case.jsp L24–36、bridge L6 | 未知碼、失敗處理缺口 | E-04、E-14、E-11 | TR-06、ST-06；缺口索引 | OTHER 僅展示 legacy 已知前綴 | AC-06、AC-12 | TODO-05；不造錯誤分支 |
| Case.jsp L38–44 | quantity 精確空／非空分支 | E-05 | BR-02、TR-07/08、MSG-03 | 警示與邊界記錄；ST-07 | AC-07、AC-08 | 空量可展示；數量後端 HANDOFF-02 |
| Case.jsp L54–58 | POST form、hidden、quantity、button | E-07 | DATA-06/09、UI-10/11、FLOW-04 | UI-10/11、隱含模式；阻止所有真實提交 | AC-07～AC-09 | 邊界已映射；不確認保存 |
| base.css L1–4 | 全部提供樣式 | E-09 | 第4.3節、CMP-01 | 按來源內嵌，不添加產品品牌／斷點 | AC-13 | 靜態結構映射；瀏覽器 TODO-06 |
| BE/api-contract L7–27、business L5–6 | 目標 mapping、單位／權限／結果／未承接 | E-10～E-13 | API-01、BR-04、HANDOFF-01～03 | 合成 legacy回應；無服務端授權模擬 | AC-03～AC-05、AC-10～AC-11 | 契約文件核對；未介接 |

共 25 個來源覆蓋列；每列已映射或具有具體缺口。不計未知 Ledger／情境／handler 內部未能盤點的行為，不報「100% 完成」。反向索引確認 prototype 的 UI-01～UI-11、FLOW-02/04、CMP-01 都有前端來源；審閱工具不分配產品 ID。

### 4.1 JSP 混合責任盤點

| LOGIC／定位 | 觸發、來源與順序 | 條件、結果／副作用 | 責任／理由 | 前端去向 | 後端映射 | 缺口 |
| --- | --- | --- | --- | --- | --- | --- |
| LOGIC-01／Case L4，E-01 | 每次進入，先讀 reviewerLabel | 供後續顯示，不改資料 | 受信任資料取得 | DATA-01、FLOW-01、BOUND-01 | E-12 明列未承接 | HANDOFF-01、TODO-01 |
| LOGIC-02／Case L5，E-02 | 名稱讀取後判斷 mode | 只有 commit 進入業務分支 | 業務觸發選擇；不因 hidden 就刪除 | DATA-09、FLOW-04 | E-12／E-13 未承接 | HANDOFF-02、TODO-03 |
| LOGIC-03／Case L6，E-02 | 提交分支先解析 quantity | 整數結果；例外無本地處理 | 業務輸入解析 | DATA-06/07、FLOW-04 | 未承接 | HANDOFF-02、TODO-03 |
| LOGIC-04／Case L7，E-02 | 解析後比較門檻 | >=4乘8，否則乘10 | 業務運算，非顯示格式 | DATA-08、BR-03 | 未承接 | HANDOFF-02、TODO-03 |
| LOGIC-05／Case L49，E-01／E-06 | 後端路徑正常返回才顯示名稱 | 「審閱者：」後動態顯示 | 呈現，與取得責任分開 | UI-02、FLOW-01 | 不需要獨立業務能力；資料相依 BOUND-01 | 名稱資料 TODO-01 |
| LOGIC-06／Case L8，E-02 | 計算後取受信任 unitId，呼叫 Ledger.store | 輸入單位、數量、計算值；實際寫入未知 | 情境及存取副作用，保持原順序 | DATA-02、BOUND-03、FLOW-04 | E-12／E-13 未承接 | HANDOFF-02、TODO-03／04 |
| LOGIC-07／Case L19–21，E-03 | 查閱先清 status，再 trim關鍵字、交接 | 舊列保留；不禁用按鈕 | 呈現及操作資料轉換 | UI-03/05、FLOW-02、BR-01 | E-10／E-12 映射 API-01／BOUND-02 | 身份／並發 TODO-04／05 |
| LOGIC-08／bridge L2–6，E-14 | 經 bridge POST JSON，再解析交 callback | 成功／HTTP錯誤處理未補造 | 交換邊界，非查閱业务實作 | BOUND-02、FLOW-02/03 | E-10～E-12 的 API-01 改用指定 wire | 非200／解析 TODO-05 |
| LOGIC-09／Case L23–36，E-04 | 回應先清 rows，再三碼分支 | 成功三欄；NONE/BLOCK 原文；其餘无追加指令 | 呈現與結果映射；rankHint不是前端運算 | UI-05～09、ST-03～06、FLOW-03 | E-11／E-12 API-01 僅承接两欄及三碼 | DATA-05 HANDOFF-03、TODO-02；其他碼 TODO-05 |
| LOGIC-10／Case L38–44，E-05 | 提交先檢查原文字是否空 | 空警示return false；非空true | 前端操作限制，不能充當業務有效性保障 | BR-02、MSG-03、FLOW-04 | 不屬 API-01 | 非空後端 HANDOFF-02 |
| LOGIC-11／Case L54–58，E-07 | 數量表單攔截後交接模式及原量 | POST同根入口；無前端結果callback | 交換與不可見動作狀態 | DATA-06/09、BOUND-03、UI-10/11 | E-12 明列未承接 | HANDOFF-02、TODO-03 |
| LOGIC-12／include及css，E-08／E-09 | 無條件動作列與表格样式 | 查閱按鈕，上距8等 | 共用呈現；不推導後端能力 | CMP-01、SCR-01 第4節 | 不適用業務操作；E-08/09 純呈現 | 像素／互動 TODO-06 |
| LOGIC-13／Case L11–60，E-06／E-07 | 首次或正常業務返回建立頁面 | 初始狀態空列、空輸入、無自動查閱或完成提示 | 結構與生命週期呈現 | FLOW-01、ST-01、UI-01～11 | 資料 BOUND-01；提交相依 BOUND-03 | 相依 HANDOFF-01／02 |

LOGIC 順序由每列描述與 FLOW 維持，不按 ID 排序執行；例如 LOGIC-05 的呈現在 LOGIC-06 正常返回之後。

### 4.2 API 與後端移交追蹤

| 契約 | 選定後端 | 需求 | 差距 | 狀態／下一步 | 解決依據／驗證 |
| --- | --- | --- | --- | --- | --- |
| BOUND-02／API-01 | E-10～E-13 fixture-v1 測試交付 | 關鍵字、授權、兩欄結果、三碼呈現 | 認證、錯誤、rankHint缺失 | 文件已對應；TODO-02／04／05 開啟 | V-04 靜態；無真實介接 |
| BOUND-01／HANDOFF-01 | E-12 fixture-v1 明列未承接 | DATA-01／UI-02 | 沒有初始化資料契約 | TODO-01 待目標承接紀錄 | 尚未取得 |
| BOUND-03／HANDOFF-02 | E-12／E-13 未定義數量 | BR-03、DATA-02/06～09 | 數量能力、保存及身份來源缺失 | TODO-03／04 待承接 | 尚未取得 |
| BOUND-02／HANDOFF-03 | E-11兩欄、E-12未承接 | DATA-05／UI-08 | 三欄可見契約與兩欄服務差距 | TODO-02 待承接或明確批准變更 | 尚未取得；不能自行裁決 |

## 5. TODO 與契約缺口

### TODO-01

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 未承接／來源缺失，開啟 |
| 問題 | reviewerLabel 的可信來源、初始及再呈現取得方式、缺失／型別異常／文字转義契約未定義 |
| 已知 | E-01、E-06 讀取與顯示；E-12 目標不承接 |
| 影響 | FLOW-01、BOUND-01、DATA-01、UI-02、AC-01；原型名稱僅合成 |
| 下一步 | 後續提供可定位的初始化或可信情境承接文件；確認缺失及文字呈現；本輪不查外部 |
| 解決條件 | 確認後端提供方式、合法來源與必要缺失反應，更新 HANDOFF-01／API索引／FLOW-01 並驗證 |
| 依賴 | 服務端情境來源；不是第二入口翻新 |
| 紀錄 | 尚未解決 |

### TODO-02

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 已知責任差距，開啟 |
| 問題 | legacy 成功每筆讀 rankHint，目標只定 rowId、label；排序提示來源、型別、空值與目標承接未知 |
| 已知 | E-04、E-06 三欄；E-11／E-12 两欄及明確未承接；不是已定 schema 的單純欄位改名 |
| 影響 | UI-08/09、DATA-05、FLOW-03／TR-03、AC-03/11、HANDOFF-03 |
| 下一步 | 提供資料承接契約或可定位批准畫面／業務改變；不能自行刪欄、填空、推算或新增 wire |
| 解決條件 | 有責任內權威承接或確認變更，更新兩端映射及案例、做三欄／變更驗證 |
| 依賴 | 後端交付及必要畫面確認；本輪不查外部 |
| 紀錄 | 尚未解決 |

### TODO-03

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 未承接業務／依賴缺失，開啟 |
| 問題 | 數量解析、≥4乘8／<4乘10、以單位保存呼叫沒有目標操作；Ledger、解析／保存异常、永久保存、交易與重送未取得；數量目的／合法範圍／計算單位未知 |
| 已知 | E-02 先解析再計算再保存；E-05 非空即前端允許；E-07 正常返回後頁面重建；E-12／E-13 不承接 |
| 影響 | FLOW-04、BR-02/03、BOUND-03、DATA-06～09、AC-08/09、HANDOFF-02 |
| 下一步 | 後續提供 Ledger 對應责任與轉換承接證據、例外及合法性契約；保留既有順序，不先設計端點 |
| 解決條件 | 適用目標產物可定位承接計算／保存／可信情境，補精確交換及可見結果；驗證門檻、例外與已確認副作用 |
| 依賴 | Ledger 缺失及 DATA-02 情境 TODO-04；本輪禁止 endpoint calls |
| 紀錄 | 尚未解決；移交文件完成不關閉 |

### TODO-04

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 可信情境／認證未知，開啟 |
| 問題 | 查閱單位由服務端供給，但身份及單位來源、認證传輸未定義；不能直接複製舊 session unitId 作 client payload；數量保存的情境有效性也未知 |
| 已知 | E-01／E-02 舊 session 讀取；E-10 不接受 client unitId 且認證未定義；E-13 服務端授權 |
| 影響 | API-01／BOUND-02、BOUND-03、DATA-02、BR-04、HANDOFF-02；不能宣稱可正式介接 |
| 下一步 | 提供適用認證與服務端情境建立契約；釐清查閱與保存責任各自有效來源 |
| 解決條件 | 可信情境及必要 header／傳輸已確認；更新 API-01 和數量承接，再做限定环境驗證 |
| 依賴 | 後端共通情境文件；本輪不猜 token/cookie |
| 紀錄 | 尚未解決 |

### TODO-05

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 目標結果／错误与並發未知，開啟 |
| 問題 | 非200、無效JSON／資料、未知碼、HTTP錯誤解析、逾時與並發回應順序未取得；legacy 回應先清列但無完整 fallback，不可以空白狀態代替錯誤處理設計 |
| 已知 | E-03 無鎖定／取消；E-04 三碼分支外無新增訊息；E-14 fetch鏈無catch；E-11只定200三碼；E-13未定排序／重送等 |
| 影響 | FLOW-02/03、TR-06、ST-06、API-01、AC-06/12；本機工具只展示單次legacy前綴 |
| 下一步 | 提供目標共通错误及回應契約、必要 legacy handler 行為；在適用環境重現並發和失敗，確認變更後才定義前端反應 |
| 解決條件 | 所有必要结果及既有／確認變更行為可定位，更新 API／FLOW／ST／MSG／AC，驗證必要分支 |
| 依賴 | 缺失 handler、無後端可呼叫環境；本輪不呼叫 |
| 紀錄 | 尚未解決 |

### TODO-06

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 未取得執行觀察／未驗證，開啟 |
| 問題 | 本輪未啟動瀏覽器；沒有 legacy 執行畫面、角色與測試情境。無瀏覽器截圖、console或network執行證據，鍵盤、焦點及返回行為仍未知 |
| 已知 | E-06～E-09 只定結構／樣式；V-01～V-04 靜態檢查不能替代實際操作 |
| 影響 | SCR-01、AC-01～AC-13；互動及視覺等價未驗證 |
| 下一步 | 後續在允許本機瀏覽器環境離線開啟原型，按索引進入各狀態，測空量警示／非空邊界／trim／重複點擊，收集console/network與截圖；取得限定 legacy觀察後比對 |
| 解決條件 | 必要本機browser檢查有實際紀錄；有適用 legacy證據才能評估像素或操作等價；真實後端仍另需環境 |
| 依賴 | 瀏覽器觀察環境、legacy可觀察資料；不將「未啟動」誤寫成「工具不可用」 |
| 紀錄 | 尚未解決 |

## 6. 原有缺陷與改良提案

沒有本輪可重現的 legacy 執行缺陷、人工確認改良或批准變更。非數字／空白數量仍交接（E-05）及沒有查閱失敗分支（E-14）已記為來源事實與 TODO-03／05，未將它們自動判為缺陷或修正。未改動產品互動限制、第三欄或訊息。

## 7. 驗證執行與交付判定

| ID | 案例／檢查 | 環境／操作 | 預期 | 實際結果／紀錄 | 結果 | TODO |
| --- | --- | --- | --- | --- | --- | --- |
| V-01 | 根、依賴、編碼、manifest hashes | 本機 Python，僅本案例；讀所有提供 inputs bytes，UTF-8解碼／SHA-256核對 | 一根，來源鎖定與manifest一致 | 六個 inputs hash相符、UTF-8 LF，無轉碼；verification.json | 通過（靜態） | 缺失依賴仍TODO-01/03/04/05 |
| V-02 | AC-01/13 部分：placeholder、文件連結／anchors、ID與HTML結構 | 本機靜態驗證腳本，無瀏覽器 | 無殘留範本；本機連結存在；11 UI、2產品flow、CMP、ST ID有效；審阅工具不誤用產品ID | 本機連結及anchors均解析，無placeholder或骨架；11個UI與FLOW／CMP／ST對照通過；沒有渲染觀察；verification.json | 通過（靜態） | TODO-06 |
| V-03 | JS 語法、離線資源檢查 | 抽出本機原型 script，node --check；檢查script/style/resource與連線原語 | JS 可解析，無fetch/XHR/WebSocket等實際呼叫或遠端資源 | node --check exit 0；資源／連線程式掃描通過，沒有远端引用或call；verification.json；未觀察console/network | 通過（靜態） | TODO-06 |
| V-04 | AC-10/11 與權威分工、LOGIC核對 | 人工逐段比對6個來源快照、規格／API／移交 | request、envelope、三碼、映射完整；每個業務項有承接或handoff | API-01與fixture-v1一致；rankHint/初始化/數量僅HANDOFF，無假端點；認證未知保留；LOGIC-01～13列明責任 | 通過（文件核對） | TODO-01～05未解 |
| V-05 | AC-01～08、AC-12/13 瀏覽器與本機互動 | 本輪未啟動browser，只有靜態HTML／JS產物 | 需實際操作、console、network、截圖 | 未執行；沒有截圖或觀察紀錄；不以源码預期偽造結果 | 未執行 | TODO-06 |
| V-06 | 原legacy畫面／UX比較 | 無提供 runtime、角色／資料或截圖 | 在限定情境比對實際畫面、鍵盤／焦點／返回 | 未執行；無像素等價、效能或瀏覽器差異結論 | 未執行 | TODO-06 |
| V-07 | API-01及HANDOFF正式介接、AC-09保存 | 契約聲明無環境，任務禁止真實呼叫 | 適用環境驗證身份、資料結果、保存與异常 | 未執行；沒有端點呼叫、業務運算／真實寫入；合成数据非正式證據 | 未執行 | TODO-01～05 |

### 本輪結論

- 已確認範圍：六個輸入快照、25個來源覆蓋列、13個LOGIC責任、4個觸發流程、三種目標查閱結果及已有前端分支；V-01～V-04只為靜態／文件檢查；verification.json記錄16項自動靜態檢查全通過，包含node --check exit 0。
- 已產生：規格、SCR-01離線原型、API-01投影、三項移交、獨立追蹤。沒有部署、改寫原件或真實介接。
- 未解：TODO-01～TODO-06；尤其rankHint、名稱初始化、數量解析／計算／保存未承接；身份、未知結果與browser缺口不能由展示数据填補。
- 覆蓋限制：25列是已取得來源的盤點分母，未知依賴內部不在其中；每列有去向，但不等同必要能力已確認或驗證。
- 交付判定：部分。單一入口、權威分工、文件分離、現有schema與來源映射可核對；必要責任未承接、未知仍存在，視覺／互動、原畫面及實際介接未执行，因此不符合完整交付條件。

## 8. 增量與變更紀錄

| CHANGE／日期 | 來源差異 | 證據 | 交付變動 | TODO | 驗證 |
| --- | --- | --- | --- | --- | --- |
| CHANGE-01／2026-10-12 | 首次，未修改任何inputs／skill／manifest／task | E-01～E-14 | v1規格、SCR-01、API-01、HANDOFF-01～03及追蹤；穩定ID首次建立 | TODO-01～06開啟 | V-01～07；靜態紀錄在verification.json，browser／介接未執行 |
