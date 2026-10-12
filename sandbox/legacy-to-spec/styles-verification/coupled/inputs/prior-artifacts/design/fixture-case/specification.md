# fixture-case：項目查閱行為規格 v1

部分交付：已提供來源可支持畫面與互動；初始化審閱者、排序提示、數量處理的目標承接與認證仍有缺口。證據與執行在 [tracking](../../renovation/fixture-case/tracking.md)，順序與後續在 [plan](../../renovation/fixture-case/plan.md)。

## 1. 範圍與意圖

唯一入口為 manifest 所指定根 JSP。納入首次呈現、查閱動作與三個已知結果分支、文字欄位、數量送出前空值提示及原有服務端責任的移交。排除另一入口內部、外部環境及後端執行；本輪沒有來源支持分頁、排序操作、取消、重試或新增視覺設計。ACT-USER 為本頁操作者；ACT-SYSTEM 為頁面生命週期與外部回應。標題描述「項目查閱」，更廣業務意圖未確認。（E-01/02/03）

## 2. 資料契約

| ID | 語意／方向 | 概念型別及已知限制 | 使用／證據與缺口 |
|---|---|---|---|
| <a id="data-01"></a>DATA-01 | 審閱者名稱／服務端到畫面 | 文字，来自服務端情境；空值呈現未確認 | UI-02/FLOW-01；E-01；[TODO-01](../../renovation/fixture-case/tracking.md#todo-01)：目標來源未承接 |
| <a id="data-02"></a>DATA-02 | 關鍵字／輸入到查閱邊界 | 文字；畫面最多 12 字元；傳遞前去掉兩端空白；空白可查阅 | UI-03/FLOW-02；E-02/03/06 |
| <a id="data-03"></a>DATA-03 | 項目代碼及名稱／結果到畫面 | 文字集合，依回傳集合順序呈現；不重排 | UI-06；E-02/06 |
| <a id="data-04"></a>DATA-04 | 排序提示／結果到畫面 | 原來源直接呈現該值，概念型別未定義 | UI-06/ST-ROWS；E-02；[TODO-02](../../renovation/fixture-case/tracking.md#todo-02)：目標缺欄位與型別 |
| <a id="data-05"></a>DATA-05 | 數量／輸入到提交邊界 | 畫面文字，僅禁止完全空字串；後續整數解讀 | UI-07/FLOW-03；E-01/02/03；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03)：目標處理未承接 |
| <a id="data-06"></a>DATA-06 | 單位識別／受信任情境 | legacy 來自服務端情境；查閱目標亦由服務端提供，不能任填 | BOUND-01/03；E-01/06/07；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03)：提交承接與情境保障未知 |
| <a id="data-07"></a>DATA-07 | 費用／後端運算及儲存 | 整數運算結果；單位未定義；不在畫面顯示 | BOUND-03；E-01；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03)：待後端承接，原型不運算 |
| <a id="data-08"></a>DATA-08 | 查閱結果／外部到畫面 | 成功、無項目、不允許；其他結果反應見 FLOW-02 | UI-05/06；E-02/06；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04)：認證及未定義交換結果 |

## 3. SCR-01：項目查閱畫面及元件

| ID | 可見內容／順序／條件 | 證據／缺口 |
|---|---|---|
| <a id="ui-01"></a>UI-01 | 文件標題及一級標題「項目查閱」 | E-03 |
| <a id="ui-02"></a>UI-02 | 「審閱者：」及名稱 | E-01/03；[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) |
| <a id="ui-03"></a>UI-03 | 「關鍵字」及文字輸入，上限 12 | E-03 |
| <a id="ui-04"></a>UI-04 | 共用動作列內「查閱」按鈕 | E-08/09；重用 [CMP-SEARCH-ACTION v1](../../../inputs/specs/action-bar.md#cmp-search-action)，本頁啟動 FLOW-02 |
| <a id="ui-05"></a>UI-05 | 狀態文字區，初始空 | E-02/03 |
| <a id="ui-06"></a>UI-06 | 結果表：項目代碼、名稱、排序提示；初始無資料列 | E-02/03；[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) 僅第三欄的目標資料缺口 |
| <a id="ui-07"></a>UI-07 | 「數量」文字輸入，初始空；接續「送出數量」按鈕 | E-02/03；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) 提交邊界 |

CMP-PAGE 覆蓋全頁基礎呈現；CMP-TABLE 覆蓋結果表及其格線；CMP-SEARCH-ACTION 行為引用既有契約，樣式只記本頁來源作用。輸入、按鈕、標題使用原生呈現，未引入新狀態或尺寸。（E-05）

## 4. 狀態及轉移

| 狀態 | 已知畫面／進入方式 | 證據／缺口 |
|---|---|---|
| <a id="st-init"></a>ST-INIT | 初次載入，查閱狀態空、無資料列、兩輸入空、審閱者顯示情境值 | E-01/03；[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) |
| <a id="st-wait"></a>ST-WAIT | 每次查閱啟動後，狀態清空，既有資料列仍保留，無 loading 或禁用 | E-02；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) 交換失敗效果未知 |
| <a id="st-rows"></a>ST-ROWS | 成功回應後依資料列呈現；不在回應時額外清空狀態文字 | E-02；[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) |
| <a id="st-empty"></a>ST-EMPTY | 無項目回應後零資料列，狀態「沒有項目」 | E-02/06 |
| <a id="st-denied"></a>ST-DENIED | 不允許回應後零資料列，狀態「不允許查閱」 | E-02/06 |
| <a id="st-unclassified"></a>ST-UNCLASSIFIED | 若收到可讀而未識別結果，資料列清空；狀態保留當時值 | E-02；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) 目標未定義其他結果 |
| <a id="st-quantity-empty"></a>ST-QUANTITY-EMPTY | 數量完全空字串時警示顯示，送出被阻止；關閉後原畫面保留 | E-02 |
| <a id="st-submit"></a>ST-SUBMIT | 非空數量通過畫面限制並到提交邊界；後續畫面未有證據 | E-01/02/03；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) |

TR-01 初始呈現；TR-02 任一查阅畫面→ST-WAIT；TR-03/04/05 可讀回應→ST-ROWS/EMPTY/DENIED；TR-06 其他可讀結果→ST-UNCLASSIFIED；TR-07 空數量→ST-QUANTITY-EMPTY→關閉前狀態；TR-08 非空數量→ST-SUBMIT。請求彼此沒有取消或過時回應排除；每個已送出請求的回應在到達時更新同一畫面。多個回應交錯時，成功不清掉其他先到回應寫入的狀態文字。（E-02/04）

## 5. 流程、邊界與規則

<a id="flow-01"></a>

### FLOW-01：首次進入／BOUND-02

ACT-SYSTEM 進入畫面時取得服務端審閱者情境，再呈現 UI-01 至 UI-07 與 ST-INIT。審閱者不能變成任填的產品欄位。（E-01/03）[TODO-01](../../renovation/fixture-case/tracking.md#todo-01)：初始化目標承接未提供，詳 [HANDOFF-01](../../integration/fixture-case/backend-handoff.md#handoff-01)。

<a id="flow-02"></a>

### FLOW-02：查閱／BOUND-01

ACT-USER 啟動 UI-04；無額外前置限制。先清空 UI-05，再將去除兩端空白的 DATA-02 交予查閱邊界；此時保留 UI-06 原資料列。收到可讀回應時先清空所有資料列，再逐分支处理：成功依回傳順序加入代碼、名稱、排序提示；無項目顯示 MSG-01「沒有項目」；不允許顯示 MSG-02「不允許查閱」；其他可讀結果不再做額外更新。結果不觸發焦點變更或數量修改。（E-02/03/04）

目標操作見 [API-01](../../integration/fixture-case/api-spec.md#api-01)，服務端判定單位查阅權限，無項目及不允許分支已承接。（E-06/07）[TODO-02](../../renovation/fixture-case/tracking.md#todo-02)：排序提示欠缺；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04)：認證與 transport／解析失敗的可見結果未知，不能假成功或補通用錯誤。沒有證據要求取消、重試、請求排序或 loading。

<a id="flow-03"></a>

### FLOW-03：提交數量／BOUND-03

ACT-USER 啟動送出數量。BR-01 若 DATA-05 是完全空字串，顯示 MSG-03 原生警示「數量不得為空」，中止提交；不清空其他值。非空文字（包含空白）通過此畫面檢核，再交予數量提交邊界。畫面檢核不保證可解讀整數。（E-02/03）

已知 legacy 後端責任：提交條件成立後，將數量解讀為整數；數量至少 4 時費用為數量乘 8，否則乘 10；再以服務端單位識別、數量和費用進行儲存，然後繼續呈現畫面。未證实儲存結果、例外回饋、交易原子性與回滾；計费不在前端重製。（E-01）[TODO-03](../../renovation/fixture-case/tracking.md#todo-03)：目標尚未承接，見 [HANDOFF-02](../../integration/fixture-case/backend-handoff.md#handoff-02)。

## 6. 樣式索引

來源僅四行樣式，未批准新設計。字型繼承與所有狀態均維持相同來源樣式。（E-05）

| CMP | 樣式契約 | 實際 CSS | 原型／tokens |
|---|---|---|---|
| CMP-PAGE | [DESIGN.md](components/CMP-PAGE/DESIGN.md) | [CSS](styles/CMP-PAGE.css) | [SCR-01](prototypes/SCR-01.html)／[tokens](styles/tokens.json) |
| CMP-TABLE | [DESIGN.md](components/CMP-TABLE/DESIGN.md) | [CSS](styles/CMP-TABLE.css) | 同上 |
| CMP-SEARCH-ACTION | [DESIGN.md](components/CMP-SEARCH-ACTION/DESIGN.md) | [CSS](styles/CMP-SEARCH-ACTION.css) | 同上 |

## 7. 原型索引

[SCR-01.html](prototypes/SCR-01.html) 可離線開啟。初始 ST-INIT；按「查閱」建立待回應请求，審閱工具選請求及合成回應再「交付回應」可进入 ST-ROWS/EMPTY/DENIED/UNCLASSIFIED。數量完全空字串可顯示原生警示；非空停止於 ST-SUBMIT 交接邊界。審閱者「示範審閱者」與結果都是合成展示資料；排序提示來源未由目標承接。工具及交接說明屬審閱層，可隱藏，沒有新增產品功能。TODO-01/02/03/04 在對應審閱說明可見。只展示前端行為，不執行服務端計費或儲存。

## 8. 驗收案例定義

| AC | 前置／事件 | 具體預期與證據 |
|---|---|---|
| AC-01 | 合成審閱者資料；進入畫面 | 標題、審閱者、欄位、表頭與按鈕依 UI 順序；兩輸入、狀態、結果空；TODO-01 仍未解（E-01/03） |
| AC-02 | 既有資料列及訊息，關鍵字「  文本  」；查閱 | 狀態立即空，資料列保留，交接文字「文本」；max 12 的原生輸入限制保留（E-02/03） |
| AC-03 | 查阅請求 R1；合成成功兩列依序 a/b，排序提示 2/1 | 表格順序 a/b，未依排序提示排序；代碼名稱提示直接文本呈現；TODO-02 未解（E-02） |
| AC-04 | 已有資料列，請求收到無項目 | 清空所有資料列，顯示「沒有項目」（E-02/06） |
| AC-05 | 已有資料列，請求收到不允許 | 清空所有資料列，顯示「不允許查閱」（E-02/06） |
| AC-06 | 數量完全空；送出及關閉警示 | 警示精確「數量不得為空」，禁止提交，畫面值與狀態保留（E-02） |
| AC-07 | 數量「4」或單一空白；送出 | 均通過前端檢核；原型停提交邊界，不計費、不儲存、不顯示成功（E-02/03；TODO-03） |
| AC-08 | 後端承接核對：數量 3、4、5；提交條件成立且有效單位 | 順序為整數解讀→費用 30/32/40→儲存單位、數量、費用；例外／原子性待查，原型不執行（E-01；TODO-03） |
| AC-09 | 本頁各可見狀態；瀏覽器 computed style | 逐 STYLE 與 DESIGN.md 預期核對，原生控制未加來源以外 CSS；來源執行畫面未知，不能宣稱像素等價（E-05） |
| AC-10 | 先送 R1，再送 R2；先交付 R2 無項目，再交付 R1 成功 | R2 清列並寫訊息；R1 填列，但「沒有項目」仍保留；無過時回應排除（E-02/04） |
| AC-11 | R1 查閱後注入未識別但可讀結果 | 資料列清空，狀態保留原值；此為來源前端分支，不代表目標支援其他碼（E-02；TODO-04） |

## 9. 前後端契約索引

BOUND-01/FLOW-02→API-01→DATA-02/03/08、TR-03/04/05、ST-ROWS/EMPTY/DENIED、MSG-01/02；排序 DATA-04 缺口 TODO-02。BOUND-02/FLOW-01→HANDOFF-01→DATA-01/UI-02/ST-INIT（TODO-01）；BOUND-03/FLOW-03→HANDOFF-02→DATA-05/06/07/ST-SUBMIT（TODO-03）。認證／未定義結果 TODO-04 在 API、DATA-08、ST-WAIT、ST-UNCLASSIFIED、FLOW-02 均維持局部標記。
