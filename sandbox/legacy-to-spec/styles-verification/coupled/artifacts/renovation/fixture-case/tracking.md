# fixture-case：翻新執行及持續追蹤 v1

[plan](plan.md) · [specification](../../design/fixture-case/specification.md) · [API](../../integration/fixture-case/api-spec.md) · [handoff](../../integration/fixture-case/backend-handoff.md)

## 1. 本輪來源及邊界

唯一根入口 `inputs/frontend/Case.jsp`；scope fixture-case；日期 2026-10-12；首次沙盒獨立 forward test。全部版本、原始位元組行數、換行與嚴格解碼結果見 [source-inventory.json](source-inventory.json)。根 UTF-8 宣告與 strict decode、可讀中文相符；其餘逐檔 UTF-8 解碼有效及內容可讀，無轉碼副本，原始行號。inventory 工具的 encoding_conclusion=unconfirmed 只表示工具沒有自行裁定 intended encoding；cp950 個別結果保留，不以鄰近來源推定。

來源快照包含一個根 JSP、一個共用 include、查閱 bridge、四行 stylesheet、共用契約及指定 backend_root inputs/backend 的 fixture-v1 sandbox 交付。沒有外部查找，沒有正式後端呼叫／執行，沒有正式 scope 擴張。部署狀態未確認，與未提供可呼叫環境分開。排除另一入口及不可取得 Ledger/module/session 內部；所有已可辨識根入口分支保留，未知部分不宣稱全覆蓋。

交付判定：部分。TODO-01/04 未解，瀏覽器檢查由 parent 獨立進行且不屬本輪已執行結果。無原系統執行畫面，不能宣稱視覺或運行等價。

## 2. 實際先後與計劃執行

| 任務／決策 | 實際執行 | 結果／限制 |
|---|---|---|
| TASK-01/DEC-01 | 先讀 task/manifest/skill/workflow/customization，執行 template selection，2026-10-12T08:47:08.887541+00:00 建立 plan；之後才讀 root/dependencies | 計劃初版實際寫入，追加 CHANGE-01 而非偽裝先知；版本及處理登錄完成 |
| TASK-02 | 搜尋 inputs/specs，核對 action bar source SHA，再建立 dependency-contracts.md | 先依賴契約，再根 specification；既有 CMP 契約直接引用，必要 bridge/CSS 依預先模擬決策先轉換 |
| TASK-03 | 根 specification → API override 及 handoff 文件 | 已知行為及未承接責任分離；沒有新端點／wire 欄位 |
| TASK-04 | 三份元件 DESIGN.md/CSS、8 token 值、11 STYLE 映射 | source-only product styles；project DESIGN 保留 Adoption Scope；DTCG 不涵蓋百分比／複合值／CSS keyword |
| TASK-05 | Node syntax/minimal DOM 檢查、靜態 links/styles/token/input integrity | V-01/02/03；native browser 未由此子任務執行 |
| TASK-06/DEC-01 | unavailable 依賴延後 | TODO-01/04；取得承接來源後先核對、更新契約再重驗，見 plan |

## 3. 證據登錄

| E | 原始來源及行號 | SHA-256 | 最小事實 | 去向／限制 |
|---|---|---|---|---|
| E-01 | `inputs/frontend/Case.jsp` 原始 1–10 行 | `90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154` | 審閱者情境、提交條件、整數解讀、兩段費用及單位儲存 | FLOW-01/03、HANDOFF-01/02、LOGIC-01/04；只支撐來源契約，非部署／原 runtime 觀察 |
| E-02 | `inputs/frontend/Case.jsp` 原始 19–44 行 | `90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154` | 查閱清狀態及 trim、回應清列與所有分支、數量空字串提示 | FLOW-02/03、DATA-02/03/04/05/08、TR、MSG、AC；只支撐來源契約，非部署／原 runtime 觀察 |
| E-03 | `inputs/frontend/Case.jsp` 原始 11–18、47–60 行 | `90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154` | 標題、stylesheet/script、審閱者、欄位、include、狀態及表格與表單 | SCR-01/UI-01/07、ST-INIT、BOUND；只支撐來源契約，非部署／原 runtime 觀察 |
| E-04 | `inputs/frontend/legacy-bridge.js` 原始 1–8 行 | `f008cb043d31d427d923e66ae33e1e98c13dd1dc9dd3f668c2fd3faf72eda09a` | POST /legacy/searchRows、JSON body、解析後 callback，沒有失敗回呼 | DEP-02、BOUND-01；不能宣稱目標沿用 path；只支撐來源契約，非部署／原 runtime 觀察 |
| E-05 | `inputs/frontend/styles/base.css` 原始 1–4 行 | `447252200c775df2b42ee0656df20334a806d91799a20602cc8f8b71d8debd99` | 唯一載入的四行來源 CSS | CMP-PAGE/TABLE/SEARCH-ACTION、STYLE-01/11；只支撐來源契約，非部署／原 runtime 觀察 |
| E-06 | `inputs/backend/api-contract.md` 原始 1–27 行 | `04215f381bc195b357b184c89d90e6f4fba521580feb7147c141a25cdb1ca802` | fixture-v1 operation、輸入、envelope、三結果、明確 legacy 對應及未承接 | API-01、DATA 映射、TODO-01/04；沙盒非正式服務；只支撐來源契約，非部署／原 runtime 觀察 |
| E-07 | `inputs/backend/business-rules.md` 原始 1–6 行 | `35e4253d281cacc662c065ed690337ae8a71f04233df8289c065828aba7614b7` | 單位權限與 OK/EMPTY/DENIED，未定義數量等行為 | API-01 受信任權限；不支持 quantity 目標承接；只支撐來源契約，非部署／原 runtime 觀察 |
| E-08 | `inputs/frontend/components/action-bar.jspf` 原始 1 行 | `61f70725865ae2fc7e49b2aea291e420255f4b1e5049728fc48740431871ff9e` | 唯一查閱按鈕及引用頁動作 | CMP-SEARCH-ACTION/UI-04/FLOW-02；只支撐來源契約，非部署／原 runtime 觀察 |
| E-09 | `inputs/specs/action-bar.md` 原始 1–11 行 | `ad476cde1e96947d8a96acf928082ab78b796a8c53eb88d9eb6cfc32b5e1e141` | fixture-component-v1，來源 SHA 相符；共用動作但不定義查阅資料 | 直接重用契約，本頁樣式另記；只支撐來源契約，非部署／原 runtime 觀察 |

## 4. 來源到契約覆蓋

| 定位 | 事實 | 去向 | 原型／案例／結論 |
|---|---|---|---|
| root 4、49 | 服务端審閱者→畫面 | DATA-01/UI-02/FLOW-01/BOUND-02/ST-INIT/HANDOFF-01 | SCR-01 合成資料；AC-01；TODO-01 |
| root 5–6、54–55 | 提交模式 hidden 狀態、request 整數解讀 | FLOW-03/DATA-05/BOUND-03/HANDOFF-02 | hidden preserved，非可見後端不執行；AC-07/08；TODO-03 |
| root 7–8 | 數量 >=4 或 <4 計费、服務端 unitId 及 store 副作用 | DATA-06/07/HANDOFF-02 | 不在原型重製；AC-08；TODO-03 |
| root 19–23 | 清狀態、trim、交換、回應先清列 | FLOW-02/BOUND-01/DATA-02/TR-02/ST-WAIT | SCR-01 request adapter；AC-02/10；已映射 |
| root 24–30 | 成功三欄、保留回傳順序 | DATA-03/04/UI-06/TR-03/ST-ROWS/API-01 | AC-03/10；第三欄目標 TODO-02 |
| root 31–35 | NONE/BLOCK 原文回饋 | DATA-08/MSG-01/02/TR-04/05/ST-EMPTY/DENIED | AC-04/05；已映射 |
| root 24–35 沒有 else | 未識別可讀結果先清列、沒有更多更新 | TR-06/ST-UNCLASSIFIED | AC-11；目標未知 TODO-04 |
| root 38–44 | empty 精確檢核、原生 alert 及阻止／允許 | BR-01/FLOW-03/MSG-03/TR-07/08/ST-SUBMIT | AC-06/07；只展示前端，TODO-03 |
| root 11–18、47–60 | 頁面語言、文件 title、頭尾及全部 UI、初值、hidden | SCR-01/UI-01/07、ST-INIT | AC-01；不省略非可見狀態 |
| action-bar 1；existing spec | 共用按鈕與引用頁 callback | CMP-SEARCH-ACTION/FLOW-02 | AC-02；相符版本重用 |
| bridge 1–8 | 請求 JSON、解析及接收，無額外 failure catch | DEP-02/BOUND-01/API-01 | target path 由 E-06；TODO-04 |
| base.css 1–4 | 所有匹配 source CSS | CMP-PAGE/TABLE/SEARCH-ACTION/STYLE-01/11 | AC-09，文件/CSS/token 已逐項，browser V-04 未執行 |
| backend fixture-v1 | queryText/outcome/rows 全 envelope、權限及字段映射 | API-01 + API-AC-01/03 | 契約對照，非 live 介接 |

### 4.1 混合責任 LOGIC

| LOGIC | 原觸發／顺序／條件 | 責任及去向 | 承接／缺口 |
|---|---|---|---|
| LOGIC-01 | 每次 root 執行先讀 reviewerLabel，後續 UI 顯示 | 服務端情境＋前端呈現；FLOW-01/UI-02 | HANDOFF-01，TODO-01 |
| LOGIC-02 | mode=commit 才 Integer.parseInt(quantity) | 整數解讀／業務處理；FLOW-03/DATA-05 | HANDOFF-02，TODO-03；錯誤未確認 |
| LOGIC-03 | 解讀後判 quantity>=4，charge=q*8 else q*10 | 後端業務運算，DATA-07 | HANDOFF-02，TODO-03；原型不執行 |
| LOGIC-04 | 運算後 store(session.unitId,quantity,charge) | 受信任情境＋資料副作用，BOUND-03/DATA-06 | HANDOFF-02，TODO-03；Ledger 未取得 |
| LOGIC-05 | 瀏覽器收到查閱按鈕／回應 | 前端呈現與交換分離，FLOW-02 | API-01 承接部分 E-06/07；rankHint TODO-02 |
| LOGIC-06 | 數量提交前完全空字串檢核 | 前端操作限制，BR-01/MSG-03 | 不能升格成後端驗證；HANDOFF-02 |

### 4.2 樣式及範本

[template-selection.json](template-selection.json) 保存各角色實際路径與 SHA-256。component-design 是 project-template-root；API 是 explicit-override；其他 fallback builtin。profile design-md+dtcg；API supplementary rule 只是文件呈現。採用 specification/prototype/plan/tracking/component-design/component-css/tokens/api-spec/backend-handoff；沒有把 template 樣式骨架當產品。

| CMP／STYLE | 實際產物 | 來源／核對 | browser |
|---|---|---|---|
| CMP-PAGE/STYLE-01/04 | [CMP-PAGE/DESIGN.md](../../design/fixture-case/components/CMP-PAGE/DESIGN.md) + [CMP-PAGE.css](../../design/fixture-case/styles/CMP-PAGE.css) | E-05 1；字型、720px、24px、#222；token page.* 對應，sans-serif 保留正文 | V-04 未執行 |
| CMP-TABLE/STYLE-05/10 | [CMP-TABLE/DESIGN.md](../../design/fixture-case/components/CMP-TABLE/DESIGN.md) + [CMP-TABLE.css](../../design/fixture-case/styles/CMP-TABLE.css) | E-05 2–3；collapse/100%/16px 0/1px solid #555/6px/left；percent及compound不錯誤token化 | V-04 未執行 |
| CMP-SEARCH-ACTION/STYLE-11 | [CMP-SEARCH-ACTION/DESIGN.md](../../design/fixture-case/components/CMP-SEARCH-ACTION/DESIGN.md) + [CMP-SEARCH-ACTION.css](../../design/fixture-case/styles/CMP-SEARCH-ACTION.css) | E-05 4；8px margin-top；共用行為版本 E-09；button 原生外觀 | V-04 未執行 |

所有 CSS 由 SCR-01.html 的 local link 實際載入；沒有 inline product style、review CSS 或後載 override。8 個 DTCG 值經局部格式檢查；未用官方 validator，不宣稱全 schema 合規。DESIGN alpha 規格版本由 supplied skill style-spec.md 指定，本輪沒有外部查核。產物雜湊見 [artifact-hashes.json](artifact-hashes.json)。

## 5. TODO 與後續

### TODO-01

開啟／未承接或未知。問題：審閱者初始化及情境來源未被目標承接；不存在時文字亦未確認。已知證據 E-01/03/06。影響：DATA-01/UI-02/FLOW-01/BOUND-02/ST-INIT/HANDOFF-01。下一步：取得 reviewer 情境與正式承接契約；更新初始化資料、flow、handoff，再驗 AC-01。解決條件：可定位適用版本的承接／確認證據，加上更新後的必要驗證；本輪尚未解決。決策為 task.txt 預先提供的沙盒 DEC-01，延後 unavailable 部分；依賴与後續順序見 [plan TASK-06](plan.md#後續任務-task-06延後)。禁止用文件生成、替身成功或沉默關閉。

### TODO-02

開啟／未承接或未知。問題：目標 rows 只含 rowId/label，缺 rankHint；legacy 型別未定義。已知證據 E-02/06。影響：DATA-04/UI-06/FLOW-02/ST-ROWS/API-01。下一步：取得排序提示資料及型別契約或批准可見契約變更；更新 API/資料/表格再驗 AC-03/09。解決條件：可定位適用版本的承接／確認證據，加上更新後的必要驗證；本輪尚未解決。決策為 task.txt 預先提供的沙盒 DEC-01，延後 unavailable 部分；依賴与後續順序見 [plan TASK-06](plan.md#後續任務-task-06延後)。禁止用文件生成、替身成功或沉默關閉。

### TODO-03

開啟／未承接或未知。問題：數量整數解讀、兩段費用、受信任單位及儲存未由目標承接；module/異常/原子性未知。已知證據 E-01/02/03/06/07。影響：DATA-05/06/07/UI-07/FLOW-03/BOUND-03/ST-SUBMIT/HANDOFF-02。下一步：取得 Ledger/情境與承接證據，先核順序及輸出，再更新 API/handoff/資料/flow，驗 AC-07/08。解決條件：可定位適用版本的承接／確認證據，加上更新後的必要驗證；本輪尚未解決。決策為 task.txt 預先提供的沙盒 DEC-01，延後 unavailable 部分；依賴与後續順序見 [plan TASK-06](plan.md#後續任務-task-06延後)。禁止用文件生成、替身成功或沉默關閉。

### TODO-04

開啟／未承接或未知。問題：認證傳輸未定義；其他結果/non-200/transport/解析失敗的目標／前端回饋缺契約。已知證據 E-02/04/06。影響：DATA-08/FLOW-02/BOUND-01/ST-WAIT/ST-UNCLASSIFIED/API-01。下一步：取得認證與錯誤契約及原 bridge failure 行為，補差距、局部規格及 AC，再核 API-AC-01/02；不能補通用錯誤。解決條件：可定位適用版本的承接／確認證據，加上更新後的必要驗證；本輪尚未解決。決策為 task.txt 預先提供的沙盒 DEC-01，延後 unavailable 部分；依賴与後續順序見 [plan TASK-06](plan.md#後續任務-task-06延後)。禁止用文件生成、替身成功或沉默關閉。

### 5.1 局部缺口位置核對

逐項回讀規格實際定義列／段的 TODO 連結；integration 亦保留對應缺口。以下位置使用顯式 ID 錨點，V-03 核對其存在及行內 TODO。BOUND 定義就在同一 FLOW 標題段，HANDOFF 定義在介接文件。

| TODO | 實際定義位置／受影響 ID | 實際契約 TODO | 任務／決策 |
|---|---|---|---|
| TODO-01 | [DATA-01](../../design/fixture-case/specification.md#data-01) | 定義列／段内 [TODO-01](#todo-01) 已回讀 | TASK-06/DEC-01 |
| TODO-01 | [UI-02](../../design/fixture-case/specification.md#ui-02) | 定義列／段内 [TODO-01](#todo-01) 已回讀 | TASK-06/DEC-01 |
| TODO-01 | [ST-INIT](../../design/fixture-case/specification.md#st-init) | 定義列／段内 [TODO-01](#todo-01) 已回讀 | TASK-06/DEC-01 |
| TODO-01 | [FLOW-01](../../design/fixture-case/specification.md#flow-01) | 定義列／段内 [TODO-01](#todo-01) 已回讀 | TASK-06/DEC-01 |
| TODO-02 | [DATA-04](../../design/fixture-case/specification.md#data-04) | 定義列／段内 [TODO-02](#todo-02) 已回讀 | TASK-06/DEC-01 |
| TODO-02 | [UI-06](../../design/fixture-case/specification.md#ui-06) | 定義列／段内 [TODO-02](#todo-02) 已回讀 | TASK-06/DEC-01 |
| TODO-02 | [ST-ROWS](../../design/fixture-case/specification.md#st-rows) | 定義列／段内 [TODO-02](#todo-02) 已回讀 | TASK-06/DEC-01 |
| TODO-02 | [FLOW-02](../../design/fixture-case/specification.md#flow-02) | 定義列／段内 [TODO-02](#todo-02) 已回讀 | TASK-06/DEC-01 |
| TODO-03 | [DATA-05](../../design/fixture-case/specification.md#data-05) | 定義列／段内 [TODO-03](#todo-03) 已回讀 | TASK-06/DEC-01 |
| TODO-03 | [DATA-06](../../design/fixture-case/specification.md#data-06) | 定義列／段内 [TODO-03](#todo-03) 已回讀 | TASK-06/DEC-01 |
| TODO-03 | [DATA-07](../../design/fixture-case/specification.md#data-07) | 定義列／段内 [TODO-03](#todo-03) 已回讀 | TASK-06/DEC-01 |
| TODO-03 | [UI-07](../../design/fixture-case/specification.md#ui-07) | 定義列／段内 [TODO-03](#todo-03) 已回讀 | TASK-06/DEC-01 |
| TODO-03 | [ST-SUBMIT](../../design/fixture-case/specification.md#st-submit) | 定義列／段内 [TODO-03](#todo-03) 已回讀 | TASK-06/DEC-01 |
| TODO-03 | [FLOW-03](../../design/fixture-case/specification.md#flow-03) | 定義列／段内 [TODO-03](#todo-03) 已回讀 | TASK-06/DEC-01 |
| TODO-04 | [DATA-08](../../design/fixture-case/specification.md#data-08) | 定義列／段内 [TODO-04](#todo-04) 已回讀 | TASK-06/DEC-01 |
| TODO-04 | [ST-WAIT](../../design/fixture-case/specification.md#st-wait) | 定義列／段内 [TODO-04](#todo-04) 已回讀 | TASK-06/DEC-01 |
| TODO-04 | [ST-UNCLASSIFIED](../../design/fixture-case/specification.md#st-unclassified) | 定義列／段内 [TODO-04](#todo-04) 已回讀 | TASK-06/DEC-01 |
| TODO-04 | [FLOW-02](../../design/fixture-case/specification.md#flow-02) | 定義列／段内 [TODO-04](#todo-04) 已回讀 | TASK-06/DEC-01 |
| TODO-01/03 | [HANDOFF-01/02](../../integration/fixture-case/backend-handoff.md) | 各自段內 tracking TODO-01/03 連結 | TASK-06/DEC-01 |
| TODO-01/02/03/04 | [API 投影](../../integration/fixture-case/api-spec.md) | 各需求及相關操作區塊局部 TODO 連結 | TASK-06/DEC-01 |

## 6. 原有行為及候選改良

交錯回應可留下「沒有項目」及成功資料同時存在（E-02）；後到舊請求未被排除。數量單一空白通過前端檢核，但可能無法解讀為整數（E-01/02）。兩者只記原有行為及 gap，没有批准的改良，因此不新增過时請求排除、trim 數量、成功文案、數字欄位或後端演算法。

## 7. 實際驗證與交付

| V | 環境／命令／案例 | 實際結果／限制 |
|---|---|---|
| V-01 | source_inventory.py 全提供 inputs，utf-8/cp950 strict；manifest SHA 對照 | 個別原始行數/換行/解碼已登錄；版本 hash 一致；不證明原 runtime |
| V-02 | Node v22.18.0，node --check prototype.js；node checks/interaction-check.cjs | 7 組 minimal DOM assertions 通過，見 interaction-results.json；AC-02/03/04/05/06/07/10/11 的資料、順序、訊息；無原生事件/渲染/alert 生命周期證明 |
| V-03 | Python static-check.py，local href/src/markdown links、骨架、source CSS、token 結構／值、input/skill hash | 結果見 static-results.json；局部格式及靜態覆蓋，不是 browser 或官方 token/DESIGN validator |
| V-04 | parent 另執行 native browser；本子任務未啟動 browser | 未執行本輪 computed style、原生互動、視覺/幾何及 screenshot 核對；parent 結果另記 |
| V-05 | live backend/API-AC-01/02、AC-08 | 未執行；無可呼叫環境且禁止後端執行；不得宣稱介接成功 |

來源支持的可見結構、文字、條件與交接已建立並可離線檢視；11 source STYLE 有三元件雙份交付。原系統運行與不可取得依賴沒有驗證，沒有宣稱完整入口或像素等價。TODO-01/04 保留，交付為部分。

## 8. 增量紀錄

CHANGE-01：首次，實際 plan 初版 → 依賴盤點追加 → necessary dependency 契約 → root specification → API/handoff/style/prototype → local checks/tracking。版本固定未變，E-01/09 初次登錄，TODO-01/04 開啟；V-01/03 局部通過，V-04/05 未執行。後續保留 IDs 並依新增 evidence 重驗。

CHANGE-02：完成本子任務 7 組 local interaction 及静態核對，links/anchors/source CSS/8 token 值/18 局部 TODO 定義全部通過。未執行 native browser 與 backend。初次 static pass 發現 artifact-hashes 尚未生成的連結，補齊實際檔後重跑通過；沒有把預期檔案當存在。

## 樣式格式續作與父代理核對（CHANGE-03／2026-10-12）

本輪先在 plan 建立 TASK-07/08 再編輯；上一輪文件與審查保留於 inputs/prior-artifacts、[格式審查](../../../inputs/prior-format-review.md)、[來源審查](../../../inputs/prior-style-review.md)。這是有審查依據的維護，不列為盲測生成。原 V-01–05、CHANGE-01/02 與「尚未 browser」敘述均為原生成回合歷史，以下補充最新證據。

| 修正 | 證據與實際處理 | 限制 |
| --- | --- | --- |
| FORMAT-01 | 原 CMP-PAGE typography 的 CSS 字串被形狀檢查拒絕；改為 `typography.page.fontFamily` 物件欄位，值仍 sans-serif；未新增字級／行高。表格區分 DESIGN 路徑、DTCG 路徑與正文規則 | 不宣稱完整官方格式驗證；八個 token 是尺寸／色彩的選定輸出，字型在 DESIGN／CSS 中保留，DTCG 本身也支援 fontFamily |
| F-01 | 依原始 physical lines 與 inventory：bridge 8 行，action-bar 契約 11 行；plan、dependency contract、E-04/09 及 bridge 覆蓋引用改成正確範圍 | 沒有改寫来源 bytes 或行號基準 |
| 範本版本 | 本輪重跑 selector，清單指向本輪 inputs／skill；保留 prior 清單 | 原產物由 prior skill 生成，此清單記本輪維護選用，不冒稱全面重新生成 |

| V | 實際檢查／證據 | 結果與限制 |
| --- | --- | --- |
| V-06 | [metadata 檢查](../../../reports/design-metadata.json)，本輪 skill/scripts/check_design_metadata.py，現有 PyYAML 6.0.3 | 三份 DESIGN.md 群組形狀及 typography 欄位通過；不涵蓋完整 schema／引用／色彩合法性／來源等價 |
| V-07 | [上一輪 Chromium 報告快照](../../../inputs/prior-browser.json)；原執行在 styles/coupled，5/5 情境、22 斷言，0 page／console errors、0 HTTP attempts | [byte-identical 核對](../../../reports/inherited-browser-check.json)：CSS、HTML、JS、tokens 與原觀察產物相同，沿用其可見樣式證據；本續作沒有重跑瀏覽器。DESIGN metadata 新版另由 V-06 核對，不能沿用舊 DESIGN 檔案 hash |
| V-08 | 本輪 structural／input-integrity、局部 source/CSS/token/link 靜態重核；引用手動回讀 | [structure](../../../reports/structure.json) 與 checks/static-results.json；實際結果於執行後確認。未知外部來源、後端与像素等價均未驗證 |

TASK-07 的格式與引用修補完成，TASK-08 的選用／繼承證據已記錄，結構結果另存實際報告。所有 product CSS／prototype 行為、API 基準與 HANDOFF 保持其來源；TODO-01–04 外部缺口仍開啟，交付判定維持部分。
