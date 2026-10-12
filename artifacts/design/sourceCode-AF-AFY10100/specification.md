# 公會通報查詢：系統行為規格

版本 0.3（2026-10-13：根頁與共用條件契約）；scope `sourceCode-AF-AFY10100`；唯一入口的證據與缺口見 [tracking](../../renovation/sourceCode-AF-AFY10100/tracking.md)。**部分交付**：根頁已知契約已還原；使用者已決定先翻新共用依賴、明細內部延後；可取得的共用契約已建立，尚缺實體／情境來源的部分保留具體TODO，尚無目標 API 基準或 legacy 執行觀察。

## 1. 範圍、角色與意圖

SCR-01 顯示「公會通報查詢」及「畫面編號：AFY10100」。ACT-01 是本頁操作者；實際角色／授權政策未知。ACT-02 是畫面生命週期；ACT-03 是識別值檢核回應。[E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)

INT-01：支援查詢、保障／保費彙整、單筆編輯、取回與明細交接的可觀察用途。頁面說明陳述彙整金額依頁面筆數加總、含本公司及產壽險通報；這是文件所述意圖，不能證明服務實際算法。[E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)

納入單頁的明示反應，跨頁只納入傳遞與新視窗；明細內部、後端運算與寫入結果另由相應權威承接。[E-07](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-07) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)

## 2. 資料語意

| ID | 語意 | 方向／型別／格式與空值 | 證據／局部缺口 |
| --- | --- | --- | --- |
| <a id="data-01"></a>DATA-01 | 身份證字號／統一編號 | 文字；可直接編輯；查詢未明示先檢核，取回會先執行共用必要檢核 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |
| <a id="data-02"></a>DATA-02 | 契約角色 | 文字代碼；I 被保人、A 要保人；依入口資料選用，未選時第一項為被保人 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="data-03"></a>DATA-03 | 保單效力 | 文字代碼；Y 有效、N 無效、A 全部；依入口資料選用，未選時第一項為有效 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="data-04"></a>DATA-04 | 同步更新公會回檔狀態 | 條件成立才可見；未勾選為缺省、勾選傳遞 Y；是否成立由外部情境提供 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="data-05"></a>DATA-05 | 姓名／生日／公會資料取回日期 | 姓名為不可編輯文字；其餘直接顯示入口資料；未提供型別、空值與時區契約 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="data-06"></a>DATA-06 | 19 項保障彙整 | 數字呈現；每項合計、同業合計、收件、承保；千分位且無小數顯示，實際精度／空值與算法需承接 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="data-07"></a>DATA-07 | 保費彙整與操作者 | 年繳、躉繳、超額(彈性)保險費；各合計、收件、承保；千分位；操作者外部提供 | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="data-08"></a>DATA-08 | 通報資料列集合 | 有序集合；每列顯示序號、選取及 16 項內容；空集合沒有另行定義空值文案 | [E-13](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-13) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="data-09"></a>DATA-09 | 選列資料快照 | 選列的只讀資料、19 金額、要保人資料、性別、公費自費及不可見識別；回填後輸入項可變更 | [E-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-05) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) |
| <a id="data-10"></a>DATA-10 | 資料寫入時間的顯示值與交接值 | 兩個獨立文字值；可見值來自行的輸入時間、交接值來自行的更新時間；不自行合併 | [E-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-05) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="data-11"></a>DATA-11 | 識別值檢核旗標 | 外部回應；只有精確等於 Y 會要求確認，其餘進入取回交接；回應傳輸與失敗方式待確認 | [E-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-04) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |

### 保障項目與資料範圍

| 項次 | 顯示名稱 | 呈現差異／證據 |
| --- | --- | --- |
| 1 | 身故 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 2 | 完全失能或最高級失能 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 3 | 失能扶助金 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 4 | 特定事故 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 5 | 初次罹患 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 6 | 醫療限額 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 7 | 醫療限額自負 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 8 | 醫療日額 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 9 | 住院手術 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 10 | 門診手術 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 11 | 門診 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 12 | 重大疾/傷病 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 13 | 重大燒燙傷 | 彙整原文「重大傷燙傷」；編輯原文「重大燒燙傷」，保留差異；[E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 14 | 癌症療養 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 15 | 出院療養 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 16 | 喪失工作能力 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 17 | 喪葬費用 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 18 | 銜接原醫療限額之自負額 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| 19 | 分期給付 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

19 項彙整排成三組，每组均為「項目、合計、同業合計、收件、承保」，按列依序為 1–3、4–6、7–9、10–12、13–15、16–18、19 與空格。金額不由原型重新計算。[E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09)

<a id="data-12"></a>

### DATA-12：受信任共用情境

外部提供功能識別、功能政策／水印旗標、登入者職編或姓名、服務端顯示時間、字型路徑，以及條件式請求耗時UUID／登入平台／系統／使用者標記／交接情境。來源E-16，只有工具存在與相應值非空時才傳遞／註冊load備份動作；合法来源与工具实际绑定仍是[TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)与[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)。字元位元組計數設定只接受正整數字串再轉整數，不合時使用2；根頁未明示使用該設定的新校驗，不能推導證號長度限制。

<a id="data-13"></a>

### DATA-13：入口訊息序列

外部訊息含描述、編號、系統識別、類型、目的資訊、返回碼、例外內容；描述／編號／例外的換行按E-17正規化。其型別、迭代長度与預設訊息物件實际语意仍依未取得權威，不从建構參數推導空集合；各已知呈現分支引用共用FLOW-13。原型空序列只屬展示前置。[TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)／[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)。

## 3. 畫面與元件

| ID | 責任／資訊順序 | 互動與條件 | 證據／缺口 |
| --- | --- | --- | --- |
| <a id="cmp-01"></a>CMP-01 | 整頁根頁明示樣式與表格資訊層級 | 標題→條件及姓名摘要→保障彙整→保費彙整→編輯區→新制通報資料明細→八則說明 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08)–[E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| SCR-01 | 公會通報查詢；18 欄明細含序號與選取 | 允許旗標成立才顯示 F8；回檔旗標成立才顯示同步選項；旗標未知不刪除已知成立分支 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [E-14](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-14) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

### 可見元素索引

UI ID 與離線原型逐項對應。下表只維護可觀察文字與操作；來源符號在 tracking 的 ui-source-map.json。顯示數字及人物為合成示例。所有列的繼承樣式與全頁事件仍受 [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) 影響。

| UI | 可见文字／語意 | 控制與初態 | 證據／局部缺口 |
| --- | --- | --- | --- |
| <a id="ui-001"></a>UI-001 | ● 公會通報查詢 畫面編號：AFY10100 | span | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-002"></a>UI-002 | 身份證字號/統一編號 | input | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-003"></a>UI-003 | 同步更新公會回檔狀態 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-004"></a>UI-004 | Y | input | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-005"></a>UI-005 | 被保人 要保人 | select | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-006"></a>UI-006 | 有效 無效 全部 | select | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-007"></a>UI-007 | F2查詢 | input | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-008"></a>UI-008 | 展示姓名 | input；不可編輯 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-009"></a>UI-009 | 保障項目彙整 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-010"></a>UI-010 | 項目 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-011"></a>UI-011 | 合計 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-012"></a>UI-012 | 收件 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-013"></a>UI-013 | 承保 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-014"></a>UI-014 | 項目 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-015"></a>UI-015 | 合計 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-016"></a>UI-016 | 收件 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-017"></a>UI-017 | 承保 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-018"></a>UI-018 | 項目 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-019"></a>UI-019 | 合計 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-020"></a>UI-020 | 收件 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-021"></a>UI-021 | 承保 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-022"></a>UI-022 | 身故 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-023"></a>UI-023 | 完全失能或最高級失能 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-024"></a>UI-024 | 失能扶助金 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-025"></a>UI-025 | 特定事故 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-026"></a>UI-026 | 初次罹患 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-027"></a>UI-027 | 醫療限額 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-028"></a>UI-028 | 醫療限額自負 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-029"></a>UI-029 | 醫療日額 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-030"></a>UI-030 | 住院手術 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-031"></a>UI-031 | 門診手術 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-032"></a>UI-032 | 門診 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-033"></a>UI-033 | 重大疾/傷病 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-034"></a>UI-034 | 重大傷燙傷 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-035"></a>UI-035 | 癌症療養 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-036"></a>UI-036 | 出院療養 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-037"></a>UI-037 | 喪失工作能力 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-038"></a>UI-038 | 喪葬費用 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-039"></a>UI-039 | 銜接原醫療限額之自負額 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-040"></a>UI-040 | 分期給付 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-041"></a>UI-041 | 保費資料彙整 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-042"></a>UI-042 | 項目 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-043"></a>UI-043 | 合計 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-044"></a>UI-044 | 收件 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-045"></a>UI-045 | 承保 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-046"></a>UI-046 | 項目 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-047"></a>UI-047 | 合計 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-048"></a>UI-048 | 收件 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-049"></a>UI-049 | 承保 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-050"></a>UI-050 | 項目 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-051"></a>UI-051 | 合計 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-052"></a>UI-052 | 收件 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-053"></a>UI-053 | 承保 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-054"></a>UI-054 | 操作者 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-055"></a>UI-055 | 年繳保費 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-056"></a>UI-056 | 躉繳保費 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-057"></a>UI-057 | 超額(彈性)保險費 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-058"></a>UI-058 | 資料編輯區 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-059"></a>UI-059 | 通報方式 | span | [E-10](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-10) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-060"></a>UI-060 | INSR_TYPE_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-061"></a>UI-061 | 公司別 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-062"></a>UI-062 | CMNY_CODE_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-063"></a>UI-063 | 被保人ID | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-064"></a>UI-064 | I_ID_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-065"></a>UI-065 | 被保人生日 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-066"></a>UI-066 | I_BIRTHDAY_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-067"></a>UI-067 | 保單號碼 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-068"></a>UI-068 | POLICY_NO_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-069"></a>UI-069 | 保單分類 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-070"></a>UI-070 | POLICY_CAT_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-071"></a>UI-071 | 險種分類 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-072"></a>UI-072 | POLICY_DUTY_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-073"></a>UI-073 | 險種 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-074"></a>UI-074 | PROD_KIND_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-075"></a>UI-075 | 保單狀況 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-076"></a>UI-076 | STATUS_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-077"></a>UI-077 | 保單狀況生效日期(受理理賠日、身故日) | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-078"></a>UI-078 | LST_CHG_DATE_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-079"></a>UI-079 | 主約保單號碼 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-080"></a>UI-080 | MAIN_POLICY_NO_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-081"></a>UI-081 | 契約生效日 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-082"></a>UI-082 | ISSUE_DATE_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-083"></a>UI-083 | 契約生效時分 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-084"></a>UI-084 | ISSUE_TIME_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-085"></a>UI-085 | 契約滿期日 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-086"></a>UI-086 | LPS_DATE_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-087"></a>UI-087 | 契約滿期時分 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-088"></a>UI-088 | LPS_TIME_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-089"></a>UI-089 | 要保書填寫日 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-090"></a>UI-090 | SIGN_DATE_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-091"></a>UI-091 | 保費 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-092"></a>UI-092 | PREM_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-093"></a>UI-093 | 保費繳別 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-094"></a>UI-094 | PAY_FREQ_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-095"></a>UI-095 | 保費繳費年期 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-096"></a>UI-096 | PAY_PERIOD_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-097"></a>UI-097 | 保單狀況生效時分 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-098"></a>UI-098 | LST_CHG_TIME_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-099"></a>UI-099 | 身故 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-100"></a>UI-100 | 身故 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-101"></a>UI-101 | 完全失能或最高級失能 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-102"></a>UI-102 | 完全失能或最高級失能 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-103"></a>UI-103 | 失能扶助金 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-104"></a>UI-104 | 失能扶助金 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-105"></a>UI-105 | 特定事故 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-106"></a>UI-106 | 特定事故 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-107"></a>UI-107 | 初次罹患 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-108"></a>UI-108 | 初次罹患 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-109"></a>UI-109 | 醫療限額 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-110"></a>UI-110 | 醫療限額 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-111"></a>UI-111 | 醫療限額自負 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-112"></a>UI-112 | 醫療限額自負 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-113"></a>UI-113 | 醫療日額 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-114"></a>UI-114 | 醫療日額 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-115"></a>UI-115 | 住院手術 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-116"></a>UI-116 | 住院手術 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-117"></a>UI-117 | 門診手術 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-118"></a>UI-118 | 門診手術 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-119"></a>UI-119 | 門診 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-120"></a>UI-120 | 門診 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-121"></a>UI-121 | 重大疾/傷病 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-122"></a>UI-122 | 重大疾/傷病 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-123"></a>UI-123 | 重大燒燙傷 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-124"></a>UI-124 | 重大燒燙傷 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-125"></a>UI-125 | 癌症療養 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-126"></a>UI-126 | 癌症療養 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-127"></a>UI-127 | 出院療養 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-128"></a>UI-128 | 出院療養 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-129"></a>UI-129 | 喪失工作能力 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-130"></a>UI-130 | 喪失工作能力 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-131"></a>UI-131 | 喪葬費用 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-132"></a>UI-132 | 喪葬費用 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-133"></a>UI-133 | 銜接原醫療限額之自負額 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-134"></a>UI-134 | 銜接原醫療限額之自負額 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-135"></a>UI-135 | 分期給付 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-136"></a>UI-136 | 分期給付 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-137"></a>UI-137 | 保經代分類 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-138"></a>UI-138 | 保經代分類 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-139"></a>UI-139 | 要保人姓名 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-140"></a>UI-140 | 要保人姓名 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-141"></a>UI-141 | 要保人身分證號碼 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-142"></a>UI-142 | 要保人身分證號碼 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-143"></a>UI-143 | 要保人出生日期 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-144"></a>UI-144 | 要保人出生日期 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-145"></a>UI-145 | 要保人與被保險人關係 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-146"></a>UI-146 | 要保人與被保險人關係 | input | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-147"></a>UI-147 | 資料寫入時間 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-148"></a>UI-148 | UPDATE_TIME_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-149"></a>UI-149 | 男 女 | select | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-150"></a>UI-150 | 無 公費 自費 | select | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-151"></a>UI-151 | 來源別代碼 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-152"></a>UI-152 | 銷售通路代碼 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-153"></a>UI-153 | 商品代碼 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-154"></a>UI-154 | 公會取回序號 | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-155"></a>UI-155 | SER_NO_text | span | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-156"></a>UI-156 | F9修改 | button；禁用 | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-157"></a>UI-157 | F10刪除 | button；禁用 | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-158"></a>UI-158 | 取消 | button；禁用 | [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-159"></a>UI-159 | 新制通報資料明細 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-160"></a>UI-160 | 選取 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-161"></a>UI-161 | 通報方式▼ | a | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-162"></a>UI-162 | ▼ | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-163"></a>UI-163 | 公司別▼ | a | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-164"></a>UI-164 | ▼ | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-165"></a>UI-165 | 保單號碼▼ | a | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-166"></a>UI-166 | ▼ | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-167"></a>UI-167 | 銷售通路 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-168"></a>UI-168 | 商品代碼 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-169"></a>UI-169 | 保單分類 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-170"></a>UI-170 | 險種分類 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-171"></a>UI-171 | 險種▼ | a | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-172"></a>UI-172 | ▼ | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-173"></a>UI-173 | 保單狀況 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-174"></a>UI-174 | 身故保額 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-175"></a>UI-175 | 醫療限額 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-176"></a>UI-176 | 醫療日額 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-177"></a>UI-177 | 契約生效日▼ | a | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-178"></a>UI-178 | ▼ | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-179"></a>UI-179 | 契約滿期日 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-180"></a>UI-180 | 要保人姓名 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-181"></a>UI-181 | 通報時間 | span | [E-12](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-12) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-182"></a>UI-182 | input-input_radio_1 | span | [E-13](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-13) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-183"></a>UI-183 | 0 | input | [E-13](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-13) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-184"></a>UI-184 | 1 展示通報 | a | [E-13](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-13) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-185"></a>UI-185 | 展示要保人1 | input；不可編輯 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-186"></a>UI-186 | input-input_radio_1 | span | [E-13](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-13) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-187"></a>UI-187 | 1 | input | [E-13](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-13) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-188"></a>UI-188 | 2 展示通報 | a | [E-13](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-13) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-189"></a>UI-189 | 展示要保人2 | input；不可編輯 | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-190"></a>UI-190 | F8即時取回公會資料 | span | [E-09](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-09) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-191"></a>UI-191 | F8即時取回公會資料 | button | [E-14](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-14) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-192"></a>UI-192 | 1. 銷售通路:1網路投保 2業務員3保經、保代 4電話行銷 5機場櫃檯 | span | [E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-193"></a>UI-193 | 2. 保單分類：1個人；2團體 | span | [E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-194"></a>UI-194 | 3. 險種分類：1人壽保險；2傷害保險；3健康保險 4.年金保險。 | span | [E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-195"></a>UI-195 | 4. 險種：01一般；02特定；03投資型；04日額型；05實支實付型；06日額或實支實付擇一型；07手術型；08重大疾病；09帳戶型；10長期看護型；11喪失工作能力；12防癌；13旅平險；14微型；15微型實支實付；16小額終老保險；17.失能扶助保險；18.登山綜合保險；19定期人壽保險(不含一年期)；20海域活動綜合保險；21一年期 | span | [E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-196"></a>UI-196 | 5. 繳別：1躉繳；2年繳；3半年繳；4季繳；5月繳；6彈性繳；9繳費期滿 | span | [E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-197"></a>UI-197 | 6. 保單狀況： 收件: 01有效；06未承保取消件；07契約註銷；11滿期(契約到期)；12鍵值欄位通報錯誤終止；15通報更正; 50一○七條/一○七條之一承保資料；51一○七條理賠資料（未滿14足歲之未成年人）；52一○七條/一○七條之一理賠資料（精神障礙或其他心智缺陷/受監護宣告尚未撤銷）。 承保: 01有效；02增額；03減額；04展期；05繳清；06契約撤銷； 07停效; 10解除契約；11滿期(契約到期) ；12鍵值欄位通報錯誤終止；20終止1:由要保人提出終止契約效力;21.終止2:主被保險人死亡，其他被保險人附同時終止或完全失能或理賠給付後終止附約;30被保險人因自然死身故；31被保險人因意外身故;32被保險人因其他原因故;50一○七條/一○七條之一承保資料；51一○七條理賠資料（未滿14足歲之未成年人）；52一○七條/一○七條之一理賠資料（精神障礙或其他心智缺陷/受監護宣告尚未撤銷）。 | span | [E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-198"></a>UI-198 | 7. 保障及保費彙整欄位，金額依頁面上的筆數加總，含本公司及產、壽險通報資料。 | span | [E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="ui-199"></a>UI-199 | 8. 即時捉取公會資料：輸入身份證字號∕統一證號，按F8即時捉取公會資料鈕 | span | [E-15](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-15) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |

### 編輯資料

選列回填的只讀資訊包括通報方式、公司別、被保人 ID／生日、保單號碼／分類／險種分類／險種／狀況及其生效日期時分、主約號碼、契約生效與滿期日期時分、要保書填寫日、保費／繳別／年期、資料寫入時間、公會取回序號、來源別、銷售通路、商品代碼。[E-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-05) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)

可輸入項目為 19 項保障金額、保經代分類、要保人姓名／識別值／出生日期／關係。性別選男(1)、女(2)；公費自費選無(0)、公費(1)、自費(2)。沒有根頁明示的數字格式檢核、最大長度或修改前确认，不增加此類規則。[E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)

## 4. 狀態與轉移

| ST | 可判定條件 | 可見結果與資料 | 證據／局部缺口 |
| --- | --- | --- | --- |
| <a id="st-01"></a>ST-01 | 尚未選列／取消完成 | 編輯區隱藏；修改、刪除、取消禁用；查詢條件與結果／彙整保留；初始資料由外部提供 | [E-06](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-06) [E-11](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-11) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="st-02"></a>ST-02 | 已選一列 | 單選已勾選；編輯區顯示，三按鈕可用；可改欄位含已選資料 | [E-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-05) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |
| <a id="st-03"></a>ST-03 | 已有檢核請求未收到回應（與 ST-01/02 並行） | 根頁選列資料保留；共用遮罩顯示並依作用中請求／訊息決定是否解除，詳見共用FLOW-12 | [E-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-04) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |
| <a id="st-04"></a>ST-04 | Y 回應正在確認（與選列狀態並行） | 原生確認文案；確認則取回交接，取消則不交接；沒有根頁明示清空或取消其他請求 | [E-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-04) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |
| <a id="st-05"></a>ST-05 | 已觸發服務或明細交接 | 後續結果／新頁内容未知；不得命名為成功、刪除完成或修改完成 | [E-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-03) [E-07](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-07) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

## 5. 規則與訊息

| BR | 條件／判斷 | 反應 | 證據／缺口 |
| --- | --- | --- | --- |
| <a id="br-01"></a>BR-01 | 取回先執行共用必要檢核；未通過 | 停止，根頁已指定 MSG-01；E-20已確認純空白通過、空字串停止；呈現模式依分類，詳見共用FLOW-17 | [E-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-02) [E-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-04) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |
| <a id="br-02"></a>BR-02 | 識別檢核回應精確為 Y | MSG-02 確認後才取回；取消不取回 | [E-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-04) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |
| <a id="br-03"></a>BR-03 | 回應旗標不是 Y | 直接取回交接；只在成功回呼已能接收回應前提下成立 | [E-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-04) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |
| <a id="br-04"></a>BR-04 | 有選列／取消 | 先逐欄回填／清空，再變更三個按鈕及編輯區；選列最後觸發造字處理 | [E-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-05) [E-06](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-06) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) |
| <a id="br-05"></a>BR-05 | 允許／回檔情境旗標成立 | 顯示相應 F8／同步勾選控制；旗標来源与否分支的后端保障未知 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [E-14](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-14) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="br-06"></a>BR-06 | 排序箭頭目前為 ▼／其他 | ▼ 改 ▲ 並傳方向 0；其他改 ▼ 並傳方向 1；隨後交給排序能力 | [E-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-02) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |

| MSG | 原文／動態部分 | 觸發／呈現／持續與終止 | 證據／缺口 |
| --- | --- | --- | --- |
| <a id="msg-01"></a>MSG-01 | 身份證字號/統一編號：不得為空值 | 取回必要檢核規則文案；顯示位置、焦點、解除方式由共用層定義 | [E-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-02) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |
| <a id="msg-02"></a>MSG-02 | 輸入值 {本次檢核識別值} 不符身份證/統一證號檢核規則，請確認，是否要繼續作業? | Y 回應原生確認；確認與取消分支分別見 FLOW-03 | [E-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-04) |
| <a id="msg-03"></a>MSG-03 | 入口執行訊息原文未取得 | 初始化最後一步；內容與顯示／關閉生命週期待共用契約 | [E-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-02) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) |

## 6. 觸發流程與結果

<a id="flow-01"></a>

### FLOW-01：入口初始化

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-02：載入入口 |
| 前置狀態／資訊 | 具備根頁結構與外部入口資料 |
| 系統反應順序 | 先定位標題，再註冊 F2/F8/F9/F10，再建立必要檢核，最後顯示執行訊息。不得自行交換順序。 |
| 分支與後置狀態 | TR-01：共用初始化結果未知；根頁初始編輯區隱藏與三按鈕禁用可確認。；ST-01 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-02) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) [TODO-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-05) |

<a id="flow-02"></a>

### FLOW-02：查詢交接

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-01：按 F2查詢 |
| 前置狀態／資訊 | 任一選列狀態；輸入值、角色、效力與表單其餘有名稱項目 |
| 系統反應順序 | 直接交接當前整份表單至 BOUND-01；根頁此流程未呼叫取回檢核。 |
| 分支與後置狀態 | TR-02：交接已觸發；查詢結果與失敗回饋未確認。；ST-05 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-03) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

<a id="flow-03"></a>

### FLOW-03：取回前識別檢核及回應

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-01：按可見 F8 取回；ACT-03：回應 |
| 前置狀態／資訊 | 允許旗標成立；共同檢核已初始化；請求各自有捕获值；共用遮罩會限制產品區再次操作，審閱工具能注入重疊請求而不將此工具視為產品能力 |
| 系統反應順序 | 1. 共用檢核不通過即停止。2. 通過後擷取本次識別值，發起 BOUND-02。3. 每個成功回應分別判斷旗標。4. Y 顯示 MSG-02（使用發起時值）；確認後 BOUND-03，取消停止。5. 非 Y 直接 BOUND-03。取回送出使用送出當刻整份表單，而非檢核時快照；不自行加入請求鎖定、取消或忽略舊回應。 |
| 分支與後置狀態 | TR-03：不通過→停止；TR-04：Y+確認→取回；TR-05：Y+取消→無取回；TR-06：非 Y→取回；失敗／解析例外依共用FLOW-12，业务結果仍未取得。；ST-03／ST-04／ST-05 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-04) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

<a id="flow-04"></a>

### FLOW-04：選列回填

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-01：按資料列單選 |
| 前置狀態／資訊 | 結果列有完整行資料；原可為 ST-01 或 ST-02 |
| 系統反應順序 | 逐欄回填只讀文本及隱藏值，再回填 19 金額、保經代及人物資料；可見寫入時間用輸入時間，交接時間用更新時間；再回填序號、性別及公費自費，來源／通路說明及商品代碼；啟用修改、刪除、取消；顯示編輯區；最後呼叫造字能力。選其他列會覆蓋未送出的編輯值。 |
| 分支與後置狀態 | TR-07：回填完成後 ST-02；造字副作用未知，原型停止在該邊界。；ST-02 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-05) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) |

<a id="flow-05"></a>

### FLOW-05：取消編輯

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-01：按取消 |
| 前置狀態／資訊 | ST-02；可有未送出的修改 |
| 系統反應順序 | 逐欄清空只讀文本、隱藏值、19 金額、人物及選項值，清空來源／通路／商品文本；解除所有列單選；禁用三個按鈕；隱藏編輯區。不清空查詢識別值、角色、效力、同步勾選、結果集合或彙整；沒有根頁定義取消進行中的檢核請求。 |
| 分支與後置狀態 | TR-08：清空完成；選項設空值而不是重置第一項，後端對缺省的接受規則未知。；ST-01 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-06](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-06) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

<a id="flow-06"></a>

### FLOW-06：修改交接

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-01：按啟用的 F9修改 |
| 前置狀態／資訊 | ST-02；編輯值可已修改 |
| 系統反應順序 | 直接交接當前整份表單至 BOUND-04；沒有根頁明示修改確認或取回必要檢核。 |
| 分支與後置狀態 | TR-09：後續保存、交易與回饋未知。；ST-05 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

<a id="flow-07"></a>

### FLOW-07：刪除交接

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-01：按啟用的 F10刪除 |
| 前置狀態／資訊 | ST-02；行識別已回填 |
| 系統反應順序 | 直接交接當前整份表單至 BOUND-05；沒有根頁明示刪除確認。 |
| 分支與後置狀態 | TR-10：後續刪除、交易與回饋未知。；ST-05 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

<a id="flow-08"></a>

### FLOW-08：明細交接

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-01：按任一行通報方式連結 |
| 前置狀態／資訊 | 該行提供資料；不要求先選列 |
| 系統反應順序 | 以點擊列的原值產生 BOUND-06，嘗試開新視窗；不讀取編輯區修改值。沒有根頁明示視窗名稱、尺寸或選列更新；鏈結亦保留本頁錨點預設動作。 |
| 分支與後置狀態 | TR-11：嘗試交接；新視窗是否開啟及明細內部未知。；ST-05（目前頁選列狀態保留） |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-07](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-07) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) [TODO-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-05) |

<a id="flow-09"></a>

### FLOW-09：排序觸發

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-01：按通報方式、公司別、保單號碼、險種或契約生效日标题 |
| 前置狀態／資訊 | 明細表及目前箭頭存在 |
| 系統反應順序 | 先反轉該標題箭頭，再傳對應欄、方向與兩個交錯色到排序能力；每欄箭頭獨立。E-24確認全部使用大寫innerHTML字串比較、0升序／其他降序，複製重排後刪舊列、不重編序號；少於2列不重排；色彩受cell級聯影响，見共用FLOW-18。 |
| 分支與後置狀態 | TR-12：▼→▲；TR-13：其他→▼；共用來源確認方向0升序，其他降序。；選列狀態保持；排序結果待查 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-02) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |

<a id="flow-10"></a>

### FLOW-10：標題重新定位

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-02：入口定位／畫面 resize／scroll |
| 前置狀態／資訊 | 標題存在時；或舊版圖層分支 |
| 系統反應順序 | 標題存在時依頁面垂直捲動距離−標題高度+30 定位；不存在時轉舊圖層處理，若舊圖層存在依頁面偏移+視窗高度−圖層高度−15 定位，每次處理建立 2 毫秒下一次計時，不取消既有計時。 |
| 分支與後置狀態 | TR-14：標題元素分支；TR-15：舊圖層分支；舊版執行可用性与實际幾何未確認。；根選列狀態保持 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-02) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) [TODO-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-05) |

<a id="flow-11"></a>

### FLOW-11：輸入及條件操作

| 契約欄位 | 內容 |
| --- | --- |
| 觸發者與事件 | ACT-01：輸入文字、選角色／效力、勾同步／修改欄位 |
| 前置狀態／資訊 | 控制已呈現；編輯欄位僅 ST-02 可見 |
| 系統反應順序 | 按原生控制變更本地值；根頁未對這些欄位註冊其他變更事件。姓名摘要不可編輯；角色、效力、性別、公費自費按已列代碼。 |
| 分支與後置狀態 | TR-16：本地值更新；共用／全頁政策未知，不能宣告所有鍵盤與貼上動作可用。；選列狀態保持 |
| 責任界線 | 呈現與本地輸入由前端負責；受信任旗標、業務檢核、資料取回／修改／刪除與結果由後端承接；未知不模擬成功。 |
| 證據與局部缺口 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

## 7. 邊界及後端責任

| BOUND | 交接語意 | FLOW | 資料／順序 | 權威與缺口 |
| --- | --- | --- | --- | --- |
| <a id="bound-01"></a>BOUND-01 | 查詢當前表單 | FLOW-02 | DATA-01–04／09–10 及當前具名稱欄位 | [E-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="bound-02"></a>BOUND-02 | 識別值檢核 | FLOW-03 | 本次擷取 DATA-01→消費 DATA-11 | [E-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-04) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="bound-03"></a>BOUND-03 | 取回公會資料 | FLOW-03 | 當前整份表單；與檢核識別值時間分離 | [E-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="bound-04"></a>BOUND-04 | 修改選列資料 | FLOW-06 | 當前表單的選列識別、只讀值與編輯值 | [E-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="bound-05"></a>BOUND-05 | 刪除選列資料 | FLOW-07 | 當前整份表單，後端如何解讀未確認 | [E-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="bound-06"></a>BOUND-06 | 新視窗明細 | FLOW-08 | 點擊列的識別、保單、保障、人物及原始來源／通路代碼；不取編輯值 | [E-07](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-07) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="bound-07"></a>BOUND-07 | 入口資料及情境 | FLOW-01 | DATA-02–10 的外部提供資料与旗標 | [E-08](../../renovation/sourceCode-AF-AFY10100/tracking.md#e-08) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

已知 legacy 傳遞符號只在 tracking 保存；[API 消費缺口索引](../../integration/sourceCode-AF-AFY10100/api-spec.md) 不建立未確認端點。[後端責任移交](../../integration/sourceCode-AF-AFY10100/backend-handoff.md) 保留初始化、檢核、取回、修改／刪除與明細需求。

## 8. 行為驗收案例定義

| AC | 契約／前置情境 | 觸發 | 具體預期／限制 |
| --- | --- | --- | --- |
| <a id="ac-01"></a>AC-01 | 初態／ST-01 | 開啟原型 | 編輯區隱藏、三按鈕禁用、19 彙整與18明細欄位有序  |
| <a id="ac-02"></a>AC-02 | 選列／TR-07 | 點第一列單選 | 顯示編輯區並逐欄回填；顯示輸入時間且隱藏交接更新時間不同  |
| <a id="ac-03"></a>AC-03 | 重選／TR-07 | 選第一列，修改身故值，再選第二列 | 全部欄位改為第二列值，未送出修改被覆蓋  |
| <a id="ac-04"></a>AC-04 | 取消／TR-08 | 選列，改值，按取消 | 編輯全部清空，選項無選取；單選解除、三按鈕禁用、編輯區隱藏；查詢及彙整保留  |
| <a id="ac-05"></a>AC-05 | 查詢／TR-02 | 未輸入識別值，選角色／效力，按 F2查詢 | 根頁直接交接當前表單，不套用取回檢核 [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="ac-06"></a>AC-06 | 修改／刪除／TR-09–10 | 選列改身故及姓名，依次點修改、刪除 | 各自交接當前表單；無根頁自加確認；後端結果待查 [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="ac-07"></a>AC-07 | Y 確認／TR-04 | 合成檢核通過發起請求；選 Y 回應；確認 | MSG-02 使用發起時識別值；交接使用送出當下表單  |
| <a id="ac-08"></a>AC-08 | Y 取消／TR-05 | 同 AC-07；取消確認 | 此回應不取回，原有選列與編輯值保留  |
| <a id="ac-09"></a>AC-09 | 非 Y／TR-06 | 合成檢核通過發起請求；選非 Y 回應 | 無確認，直接交接當前表單  |
| <a id="ac-10"></a>AC-10 | 重疊回應／FLOW-03 | 發起請求1識別 DEMO1，再發起請求2識別 DEMO2；改輸入 DEMO3；先交付2的Y回應並確認，再交付1的Y回應並取消 | 先確認文字用 DEMO2、取回表單用 DEMO3；後確認文字用 DEMO1，取消不增加交接；沒有取消其他請求  |
| <a id="ac-11"></a>AC-11 | 條件渲染／BR-05 | 審閱工具分別切換兩旗標 | 同步選項／F8 按鈕各自出現或隱藏；不宣告後端授權成立  |
| <a id="ac-12"></a>AC-12 | 排序／TR-12–13 | 對五個可排序標題各連按兩次 | 箭頭先▲方向0，再▼方向1；其他標題箭頭獨立；按來源helper實際重排，序號不重新編排  |
| <a id="ac-13"></a>AC-13 | 明細／TR-11 | 選第一列改金額，再點第二列明細連結 | 交接第二列原始全部參數，選列不變；不宣告明細內部 [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| <a id="ac-14"></a>AC-14 | 初始化順序與快捷鍵 | 在具備共用依賴的環境載入並按 F2/F8/F9/F10 | 定位→註冊→建立驗證→訊息；快捷鍵對應原按鈕，禁用／缺按鈕行為待查 [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |
| <a id="ac-15"></a>AC-15 | 共用失敗／空值／全頁政策 | 取得依賴契約後檢查 Ajax 例外、空值正規化、訊息關閉、造字與全頁事件 | 預期由取得的來源補充，未取得前不得用成功或通用文案代替 [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) |
| <a id="ac-16"></a>AC-16 | 標題生命週期 | 在瀏覽器 resize、scroll；另具備舊圖層環境觸發不存在標題分支 | 符合 FLOW-10 各公式及獨立2毫秒計時鏈；舊圖層未驗證 [TODO-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-05) |

## 9. 原型與樣式索引

[SCR-01.html](prototypes/SCR-01.html) 一份原型，選列進入 ST-02、取消回 ST-01。直接按服務操作只在獨立審閱工具記錄已知交接；F8 執行本機已取得的必要檢核，通過即建立合成請求與遮罩，等待審閱層交付回應。由審閱工具注入「檢核通過」、選請求及回應，可檢查 FLOW-03 已知分支，這不是後端檢核能力。根頁狀態 metadata 表示選列狀態；並行請求与交接只在審閱工具顯示，ST-03–05 未模擬成已完成業務狀態。

合成示例：兩筆 DEMO 列、展示姓名／公司、各彙整數字獨立為 12,345；不是個資、有效證號、真實公司或後端計算。條件旗標由審閱層注入，不代表實際授權。

CMP-01 交付 [DESIGN.md](components/CMP-01/DESIGN.md) 與原型實際載入的 [CSS](styles/CMP-01.css)。僅還原根頁明示背景、版面、對齊、可見性及層級；候選共用CSS的字型、表格色彩、欄位、按鈕已投影；实际cssBase映射及圖片仍是 [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02)，全頁事件／訊息／造字為 [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)，快捷鍵／檢核／實際排序已取得共用來源並可離線操作；日期工具編碼及環境差異仍是 [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03)。所有 UI 透過 CMP-01 繼承这些待決缺口。

額外 [tokens.json](styles/tokens.json) 採 DTCG 2025.10，只投影明示背景及固定長度；百分比、定位公式和表格原生屬性保留 CSS／文件。未取得 legacy 執行畫面，不能宣告像素等價。[TODO-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-05)

## 10. 共用契約引用与補充狀態

[CMP-02–04／FLOW-12–18](shared-contract.md) 是本頁所消費的共用定義，根頁不再重複維護其詳細規則。來源版本與E-16–25見tracking；本頁只引用其初始化、檢核、請求完成、訊息、鍵盤、排序与全頁條件用法。來源取自可取得的工作區候選，不代表自訂tag或部署映射已確認。

| CMP | 本頁用法 | DESIGN | 載入CSS | 局部缺口 |
| --- | --- | --- | --- | --- |
| <a id="cmp-02"></a>CMP-02 | 全頁候選字型、欄位、按鈕与表格 | [DESIGN](components/CMP-02/DESIGN.md) | [CSS](styles/CMP-02.css) | TODO-02：cssBase映射與圖像 |
| <a id="cmp-03"></a>CMP-03 | 檢核請求遮罩；條件式自訂訊息窗 | [DESIGN](components/CMP-03/DESIGN.md) | [CSS](styles/CMP-03.css) | TODO-01/02：實際系統分類／底部環境與圖片 |
| <a id="cmp-04"></a>CMP-04 | 政策成立時全頁事件及列印限制 | [DESIGN](components/CMP-04/DESIGN.md) | [CSS](styles/CMP-04.css) | TODO-01/04：受信任政策／水印情境与稽核後端 |

UI-202 遮罩、UI-203 自訂訊息視窗、UI-204 訊息標題、UI-205 確定、UI-206 拖曳框對應來源E-19/21；掛在body且保留全域繼承。<a id="st-06"></a>ST-06為訊息移除／無活動遮罩隱藏；<a id="st-07"></a>ST-07為自訂訊息已掛載；<a id="st-08"></a>ST-08為拖曳移動中框存在且訊息未掛載；ST-03為有請求活動且遮罩顯示。這些狀態与根頁選列ST-01/02並行，root metadata只維護選列狀態，訊息／遮罩有自己data-state-id。

可用的合成情境：預設subsystem=AF（僅展示路徑分類，不是已確認部署）；URL加入?subsystem=DS檢查聚合檢核提示与自訂訊息分支；?policy=Y檢查條件全頁政策。審閱工具允許發起額外合成請求、選擇回應交付次序与注入訊息，不属于產品操作需求；全頁政策作用域仍包含審閱區。

上述所有共同使用位置仍局部連到 [TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01) [TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02) [TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03) [TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) [TODO-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-05)。

後置補充：根頁識別值成功回呼只讀識別旗標，未先依業務返回碼決定能否取回；共用完成階段其後才處理業務訊息。E-04/18/19。所有服務結果仍是[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)。

<a id="st-09"></a>

## 水印條件呈現

CMP-05／ST-09／UI-207引用[共用水印定義](shared-contract.md#cmp-05)、[DESIGN](components/CMP-05/DESIGN.md)与[CSS](styles/CMP-05.css)。由審閱工具URL?watermark=Y進入已知成立分支；其旗標、DEMO_USER、2020-01-01 12:00:00皆为合成前置，實際身份／日期／設定仍是[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)。E-16/26，字型或实际frame环境[TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)，跨frame與legacy執行驗證仍是[TODO-05](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-05)。
