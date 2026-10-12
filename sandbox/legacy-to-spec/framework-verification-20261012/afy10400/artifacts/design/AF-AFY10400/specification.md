# 公會通報下傳作業：前端系統行為規格

| 項目 | 內容 |
| --- | --- |
| Scope／版本 | AF-AFY10400／v2，部分契約；初輪快照與失敗保留於追蹤 |
| 功能邊界 | 單頁選擇收承方式與商品屬性、維護被保人及多筆保單、逐列檢查、接收逐列匯出結果、交接下載 |
| 連結 | [證據與追蹤](../../renovation/AF-AFY10400/tracking.md)、[本頁共用契約](common-contracts.md)、[原型](prototypes/SCR-01.html)、[API 消費](../../integration/AF-AFY10400/api-spec.md) |

## 1. 意圖、邊界與觸發者

INT-01：使用者對同一組收承方式與商品屬性，把同一被保人的多筆保單集中一列，分組匯出供下載；多種組合需分次匯出。畫面说明要求 Google Chrome，多筆保單以 Enter 分隔。E-02/03；匯出 Excel 意圖有 E-23 文件依據。

ACT-01 為頁面使用者，可新增、刪除及匯出；ACT-02 為入口生命週期；ACT-03 為服務回應；ACT-04 為外層通知／政策情境。來源沒有證明本頁可取代服務端授權。[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)：可信情境与目标承接未確認，E-06/07/08。

BOUND-01 匯出、BOUND-02 下載、BOUND-03 複製軌跡、BOUND-04 可信情境／浮水印為已知交接。其他入口內部、業務查詢与檔案生成由接收者負責，不在前端重製。

缺口索引：TODO-01 入口／底部／外部初始化；TODO-02 回應與下載契約差距；TODO-03 共用訊息分支情境與外部訊息呈現能力；TODO-04 可信功能政策與外部後端責任；TODO-05 未提供樣式、圖片、字型及浮水印庫；TODO-06 date 載入副作用；TODO-07 瀏覽器與正式服務未驗證。詳細均在 [tracking 缺口](../../renovation/AF-AFY10400/tracking.md#todo-01)；以下受影響位置各自引用。

## 2. 資料語意

| ID | 語意與概念型別 | 允許值、必填、初始與生命週期 | 證據／局部缺口 |
| --- | --- | --- | --- |
| DATA-01 | 收承方式，文字代碼 | 依序 L=承保、R=收件；初始 L；單次匯出共用一值 | E-03 |
| DATA-02 | 商品屬性，文字代碼 | 依序 AT=個險、BG=團險、CB=意外險；初始 AT | E-03 |
| DATA-03 | 有序被保人列集合 | 初始 0 列；每列 ID 文字最多 10 字、保單多行文字無來源最大長度；新增空列、刪除只移除指定列；匯出有列時兩者皆不得精確空字串；前端不自動去除頭尾空白、不驗證合法證號，空集合可走交接 | E-01/04；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)：目標空集合／換行业务規則未完整確認 |
| DATA-04 | 每個被保人的結果文字映射 | 回應後以當時現有列的當時 ID 找結果；成功與拒絕均填；新增列結果為空，既有結果不因修改輸入、重新送出、增刪其他列自動清除 | E-04/05；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)：目標拒絕 回應沒有逐列結果 |
| DATA-05 | 匯出檔名與下載交接資訊 | 成功回應帶檔名，先回填列再立即交接下載；前端不自產檔名、日期或加密路徑 | E-05/17；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)：旧参数链与目标 binary 不同；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)：接收者承接 |
| DATA-06 | 入口／非同步訊息、底部旗標 | 入口描述、編號、系統、類型、URL、回傳碼、異常为有序集合；含換行与空值正規化；底部回復旗標消费後清空 | E-09/11；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)：来源机制与底部；[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)：分支選擇／外部訊息呈現能力 |
| DATA-07 | 可信功能政策、員工識別、服務端時間 | 決定列印／複製政策及浮水印；不得成為可任填產品欄位 | E-06/07/08；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)：合法來源与目标承接；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)：庫與字型 |
| DATA-08 | 複製去重記錄與獨立到期事件 | 去除連續空白后的上次全文；不同非空复制建立獨立 60 秒到期，舊到期不取消 | E-07；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)：外部記錄承接 |
| DATA-09 | 列識別計數，非可見整數 | 首次載入 0，每次新增先加一；刪除不倒退、不復用；与画面順序分離 | E-01 |

## 3. 邊界互動

| ID | 觸發、輸入與責任 | 接收結果、可見反應与停止邊界 | 證據／缺口 |
| --- | --- | --- | --- |
| BOUND-01 | FLOW-04 檢查通过，向匯出責任者交付 DATA-01/02 及 DATA-03 两个有序並行集合；換行保持每列多筆語意 | FLOW-05 逐列回填；檔案查詢／生成責任属接收者 | E-04/05/10/22；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) 回應差距；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) 稽核承接 |
| BOUND-02 | FLOW-05 成功回填後立即交付 DATA-05 | 舊交接取得加密資訊後交同頁檔案接收者、不新開視窗；目标已确认直接檔案回應，转换选择未確認 | E-05/17/22；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)、[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) |
| BOUND-03 | FLOW-08 啟用政策下复制與上次不同非空内容；传送 DATA-08 内容、功能、原長度、時間 | 紀錄接收後的結果未知；不能宣稱稽核已寫入 | E-07；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) |
| BOUND-04 | 首次載入接收 DATA-07，依政策條件顯示浮水印與全頁限制 | 功能設定与浮水印實際輸出未知，條件分支的已知反應保留 | E-06/08；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)、[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) |

## 4. 畫面、元件與元素

SCR-01：頂部「公會通報下傳作業」、右側「畫面編號：AFY10400」，下方「公會補通報作業」，依序三行操作說明、組合選項、資料表標題及匯出按鈕。原画面宽 97% 主框、标题 30 高；資料列欄位依序刪除、被保人 ID、保單號碼、匯出結果；初始沒有資料列。E-02/03。

| UI | 標籤／順序與操作 | 已知條件与尺寸 | 證據／局部缺口 |
| --- | --- | --- | --- |
| UI-01 | 畫面標題、編號 | 無操作；頂部全寬 | E-02；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 圖片／難字及後載 CSS |
| UI-02 | 公會補通報作業及三條說明 | Chrome、組合分次、Enter分隔的原文；红字 Chrome/Enter | E-03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 圖示與後載 CSS |
| UI-03 | 收承方式選項 | DATA-01；標籤／值区各 20% | E-03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 繼承 cascade |
| UI-04 | 商品屬性選項 | DATA-02；標籤20%、值40% | E-03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 繼承 cascade |
| UI-05 | 被保人 ID 標題内「新增一列」 | FLOW-02；沒有新增列後自動聚焦的依據 | E-01/03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) cascade |
| UI-06 | 每列「刪除此列」 | FLOW-03；無確認提示；其他列保持 | E-01；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) cascade |
| UI-07 | ID 输入、保單多行输入 | ID size12、max10；保單 rows3 cols30；不默认修剪 | E-01/04；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 字型/cascade |
| UI-08 | 每列匯出結果 | 維持沿文字方向的起始對齊，前三個資料格置中規則不適用於本格；DATA-04；按回應時現有 ID；原呈現容許换行標記 | E-05；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) 拒絕结果／目標文字呈現差距；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) cascade |
| UI-09 | 「匯出檔案」与等待遮罩 | FLOW-04；等待遮罩阻隔指標，未禁用控制／未增加取消操作 | E-03/11；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 遮罩圖像/cascade |
| UI-10 | 原生提示、条件自訂「網頁訊息／確定」 | FLOW-06/09/10；若建立／取得遮罩且焦點在按鈕類控制，嘗試聚焦所屬視窗；底部為外部元件，不自創本頁區塊 | E-09/11/12；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01) 底部；[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03) 選用／外部訊息呈現能力；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 繼承；[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07) 實測 |

所有 UI 的載入副作用亦受 [TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06) 未解碼依賴影响，此為共用 CMP-PAGE 定義的缺口；未知來源不改寫为不存在。CMP-PAGE 全頁排版／字型与条件列印样式；CMP-FORM 表格、按钮、字段；CMP-COVER 全頁遮罩；建立或取得時，若當時焦點位於按鈕類控制，嘗試聚焦所屬視窗；失敗只留下診斷記錄，瀏覽器實际效果連 TODO-07（E-11 原來源條件）；CMP-MESSAGE 自訂訊息樣式。入口訊息與政策行為重用 [common-contracts](common-contracts.md) CMP-ENTRY/REQUEST/POLICY/DOWNLOAD，版本v1。CMP-PAGE [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)/[TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06)；CMP-COVER [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)；CMP-MESSAGE [TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)/[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07)。

| 元件 | 樣式規格 | 原型實際載入 CSS | 畫面與證據 |
| --- | --- | --- | --- |
| CMP-PAGE | [DESIGN](components/CMP-PAGE/DESIGN.md) | [CSS](styles/CMP-PAGE.css) | SCR-01、所有 ST；E-02/08/20 |
| CMP-FORM | [DESIGN](components/CMP-FORM/DESIGN.md) | [CSS](styles/CMP-FORM.css) | SCR-01、ST-01/02/04；E-01/03/20 |
| CMP-COVER | [DESIGN](components/CMP-COVER/DESIGN.md) | [CSS](styles/CMP-COVER.css) | ST-03/05；E-11 |
| CMP-MESSAGE | [DESIGN](components/CMP-MESSAGE/DESIGN.md) | [CSS](styles/CMP-MESSAGE.css) | ST-05；E-12/20 |

## 5. 狀態与轉移

狀態為可组合描述，不假定每次只有一个。ST-01 無列；ST-02 至少一列可编辑；ST-03 活動請求／遮罩顯示；ST-04 列结果已回填；ST-05 原生／自訂／外部訊息；ST-06 政策／浮水印條件上下文。任一輸入修改不自動清除 ST-04。ST-03 缺圖片 [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)、需瀏覽器 [TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07)；ST-04 目標拒絕資料 [TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)；ST-05 入口与底部 [TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)、選用 [TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)、樣式 [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)；ST-06 可信来源 [TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)、庫 [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)。所有狀態的載入副作用由 CMP-PAGE 引用 TODO-06。E-01/05/07/09/11/12。

| TR | 起始／条件 | 反應及終態 | FLOW／證據 |
| --- | --- | --- | --- |
| TR-01 | 入口載入 | 初始选项与 0 列 ST-01；入口讯息可叠 ST-05 | FLOW-01、E-01/03/09 |
| TR-02 | ST-01/02 新增 | 空列、计数+1、重新交錯色；ST-02 | FLOW-02、E-01 |
| TR-03 | ST-02 删除 | 删除指定列、重新交错色；最后一列删除则 ST-01 | FLOW-03、E-01 |
| TR-04 | 匯出逐列判定，任一精確空值 | MSG-01、停止交接；列資料及结果保留 | FLOW-04、E-04 |
| TR-05 | 當前列非空、後方有相同精確 ID | MSG-02、停止；先于後方列的空值檢查 | FLOW-04、E-04 |
| TR-06 | 全部通過或 0 列 | BOUND-01、ST-03 | FLOW-04、E-04/11 |
| TR-07 | 舊成功回應 | 回填 → BOUND-02 → 共用完成訊息；ST-04 可叠 ST-05 | FLOW-05/06、E-05/10/11；TODO-02 见 DATA-04/05 |
| TR-08 | 舊拒絕回應 | 回填、无下載 → 共用完成訊息；ST-04 可叠 ST-05 | FLOW-05/06、E-05/11；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) |
| TR-09 | 已解析回應缺失／傳輸失敗／回呼例外 | 无已知正常回填保证，进入共用完成或診斷分支；未知結果不命名成功 | FLOW-06、E-10/11；[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03) |
| TR-10 | 入口回復旗標 | 清旗標后停止，無入口警示 | FLOW-01、E-09；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01) |
| TR-11 | 自訂訊息首键／确认／拖曳 | CMP-MESSAGE 的完整順序，关闭或保持 ST-05 | FLOW-09/10、E-12 |
| TR-12 | 啟用政策下全頁事件／copy 到期 | 阻断或轨迹交接、独立清去重；ST-06 | FLOW-08、E-07；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) |

## 6. 規則與訊息

BR-01：逐列按順序，先检查本列任一值精確等於空字串；成立就原生提示并停止；不将全空白當前端空字串。BR-02：當前列非空後立即与其后各列 ID 精確比对；相同就提示并停止，因此首列 A、第二列 A 且保單空，会先重覆提示。BR-03：有零列时沒有可檢查列，直接交接；不能添加「至少一列」。BR-04：列颜色按显示位置重新计算，第一列 #EEF1A7、第二列 #FAFBE1 交錯；刪除重新排列。E-01/04。BR-05 舊成功＝訊息代碼0，不是 傳輸成功；目標判定见API，差距 [TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)。BR-06 共用分支、首键、自訂去重、尺寸、複製獨立到期事件，引用 common-contracts v2；E-07/09/11/12。

| MSG | 原文、出現與关闭 | 證據 |
| --- | --- | --- |
| MSG-01 | 「第{目前可見列號}列的被保人ID或保單號碼不得為空值，若不需要請刪除該列」；BR-01 原生阻断警示；确认后保持输入，无自動聚焦 | E-04 |
| MSG-02 | 「被保人ID：{ID}有重覆出現，請合併在同一列處理」；BR-02 原生警示；確認後不送出 | E-04 |
| MSG-03 | 入口／異步动态訊息原文及前缀，逐條见共用契約；不以「成功／失敗」替代 | E-09/11；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)、[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03) |
| MSG-04 | 自訂視窗「網頁訊息」「確定」，空值「(無訊息內容)」 | E-12 |
| MSG-05 | 「依據資安政策，不開放列印功能」「依據資安政策，不開放剪下功能」「依據資安政策，不開放全選功能」「依據資安政策，不開放頁面儲存功能」；copy 的 Ctrl+Q 說明在來源字典中，实际 copy未呼叫此提示，不当作已触發文案 | E-07；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) |
| MSG-06 | 診斷 Error、url、params、Exception及逐屬性，見共用契約 | E-11 |

## 7. 觸發流程

| FLOW | 觸發者／事件、起始及輸入 | 條件、系統反應順序 | 可見結果／後置与責任界線 | 證據／缺口 |
| --- | --- | --- | --- | --- |
| FLOW-01 | ACT-02 首次進入；尚未接受使用者事件 | 初始化列識別計數及本頁列集合 → CMP-ENTRY；外部初始化能力存在時執行並登錄視窗尺寸變更反應；同頁没有绑定快捷键 | ST-01、L/AT、无列；按条件入口消息；外部可信資料不由前端生成 | E-01/03/09/14/15；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)、[TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06) |
| FLOW-02 | ACT-01 UI-05，ST-01/02 | 計數加一 → 末尾空列 → 刪除、ID、保單、空結果 → 重排色 → 文档冒泡清底部 | ST-02；现有列不變，不加入聚焦 | E-01/09；FLOW-07 |
| FLOW-03 | ACT-01 UI-06，指定列存在 | 刪除指定列 → 重排色 → 冒泡清底部 | ST-01或02；不更改计数或其他值；无確認对話 | E-01/09；FLOW-07 |
| FLOW-04 | ACT-01 UI-09，ST-01/02，可包含旧结果 | BR-01 → 当前列 BR-02 → 下一列；第一命中停止；全部或0列通過则 BOUND-01，遮罩与活动記錄；冒泡清底部 | MSG-01/02 或 ST-03；不清結果、不自動去除頭尾空白、无新增取消；业务检核仍属接收方 | E-04/10/11；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)、FLOW-07 |
| FLOW-05 | ACT-03 BOUND-01 旧响应，ST-03；捕捉到的列集合仍反映当前画面 | 成功／拒絕均依當時 ID 填當時列结果；成功填完才 BOUND-02；拒絕不下載；完成處理在回呼之後 | ST-04；不能改成请求时快照結果、不能丟棄較早請求回應；後到回應覆蓋现有结果；目標差距未確認 | E-05/10/11/17；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) |
| FLOW-06 | ACT-03 请求创建、完成、傳輸／回呼异常 | 兩種不同先後的回應處理模式、底部、原生／自訂及成功僅收遮罩的子情境、空描述、長編號、文字回應、診斷順序引用 CMP-REQUEST v2；建立或取得遮罩時若當時焦點在按鈕類控制，嘗試聚焦所屬視窗，效果未確認；与FLOW-05先后不同不可合併 | ST-03/05 保留活動生命周期；未確認者停在已知分支；本頁沒有已知逾時設定；聚焦效果未確認 | E-10/11/13；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)、[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03) |
| FLOW-07 | 全文檔冒泡按鈕／submit點擊 | 本按钮反應後清底部；自訂確定停止冒泡所以不清；清除錯誤吞下 | 本页資料不變；底部受接收者负责 | E-09/12；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01) |
| FLOW-08 | ACT-02/01，政策启用时載入、全页键盘/剪贴/右键/列印與到期 | CMP-POLICY；作用於全頁及所屬視窗，在控制本身反應前攔截；複製有獨立到期事件及原序資料轉換 | 阻断MSG-05或BOUND-03；複製不阻斷；可信來源與记录结果未知 | E-06/07/08；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)、[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) |
| FLOW-09 | ACT-03 自訂訊息顯示／ACT-01 首鍵或確定，ST-05 | CMP-MESSAGE 正規化、去重、增長、重定位、聚焦；每個首鍵反應先解除自身；只有視窗仍附著於頁面才執行關閉鍵及阻斷；確定順序 | 保持或關閉ST-05；不暗加持续Esc监听；停止确认冒泡 | E-12；[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07) |
| FLOW-10 | ACT-01 自訂标题按下→全頁指標移動→放開 | 保存偏移、拖曳框、隐藏真視窗、放開复位与解除／重建监听 | 視窗移動；不改訊息累積或資料 | E-12；[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07) |

## 8. 驗收案例定義

均為合成資料，无真实個資；V 實際結果在 tracking。未解案例不宣稱可通過。

| AC | 前置／事件 | 明確預期與關聯 | 證據／缺口 |
| --- | --- | --- | --- |
| AC-01 | 初次開啟 | L/AT、0列、三条說明与四欄；FLOW-01 | E-01/03；TODO-01/06 |
| AC-02 | 新增2列、刪第一、再新增 | 第一色#EEF1A7，第二#FAFBE1；保留其他值；识别不復用；FLOW-02/03 | E-01 |
| AC-03 | 第一列 ID空，保單X → 匯出 | 精確MSG-01第1列；沒有pending交接 | E-04 |
| AC-04 | 第一列DEMO000001/P1、第二同ID且保單空 | 先MSG-02，再終止；不得先第2列空警示 | E-04 |
| AC-05 | ID/保單均單一空格、及另一次0列 | 前端空字串檢核不攔；後端结果未知；不得新增至少一列 | E-04；TODO-02 |
| AC-06 | 有效兩列 P1 LF P2，選R/CB → 匯出 | 輸出有序平行集合；保單换行轉CRLF；ST-03、不清舊结果 | E-04/10 |
| AC-07 | R1请求ID=A后把現有ID改B；返回結果對應 A=a、B=b及檔名 | 回填b；回填後下载交接；与请求A映射不同；FLOW-05 | E-05 |
| AC-08 | 请求R1→R2；R2 結果對應 A=second先返回，R1 結果對應 A=first后返回 | 結果先second后first；各自成功均依各自檔名交接，没有忽略較舊回應的限制；活動依實際交付减 | E-05/10/11 |
| AC-09 | 舊拒絕回應帶 A=原因 | 回填原因、沒有下載、共用錯誤訊息；目標拒絕回應沒有逐列結果，不能模擬舊回填 | E-05/22；TODO-02 |
| AC-10 | 入口有／無底部、回復旗標、代碼0/99/5、異常 | 依 CMP-ENTRY 逐分支前缀、首笔通知、回復清旗标并停止；外部訊息呈現能力的分支未知 | E-09；TODO-01/03 |
| AC-11 | 共用回應完成：各呈現模式、成功僅收遮罩子情境、空描述、長度>17編號、僅文字、傳輸失敗、處理例外 | CMP-REQUEST所有已知分支／順序；診斷原文；没有正常回填保障的情況不当成功 | E-10/11；TODO-01/03 |
| AC-12 | 自訂訊息空值、同内容重複、短→長→短 | 空占位、按規則去重与累積，宽只增、每次居中、聚焦確定 | E-12；TODO-07 |
| AC-13 | 初次訊息，首鍵a，再Enter；另次重開首Esc；按钮关→重開首鍵组合 | a先自除监听，后Enter不close；首Escclose；旧listener身份分别自除，不能移除新实例 | E-12；TODO-07 |
| AC-14 | 自訂訊息标题按下、移動(+50,+30)、放开、再拖 | 框按偏移移动，真视窗移出；放開復位／解除移動及放開反應／重新接受按下 | E-12；TODO-07 |
| AC-15 | 启用政策，在產品區之外的審閱區域发Ctrl+A/X/S/P與右键 | 全頁／所屬視窗先行攔截並阻斷；右键无固定訊息；列印內容符合MSG-05 | E-07；TODO-04/07 |
| AC-16 | t0复制A，t30复制B，t60 A到期，t61再复制B | A/B各送一次；t60清B记录，t61再送B；空选择不送，同文本未到期不送；>5000截4997+...，长度送原始值 | E-07；TODO-04 |
| AC-17 | 新增/删除/空值匯出點擊；自訂確定 | 前三者按动作后尝试清底部；確定不冒泡清底部 | E-09/12；TODO-01 |
| AC-18 | 打开原型並实测所有已知状态的style | 核對四CMP DESIGN/CSS selector，特别root padding10px及讯息增長／拖曳；沒有legacy画面不宣稱像素等價 | E-20/12；TODO-05/07 |
| AC-19 | 建立／取得遮罩時焦點在按鈕類、文字輸入或頁面本身；另令焦點取得失敗 | 只有按鈕類嘗試聚焦所屬視窗；失敗僅診斷且不變成產品成功／錯誤訊息；不保證瀏覽器轉移可見焦點 | E-11；[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07) |
| AC-20 | 顯示訊息 → 按下標題 → 指標移動使真視窗離開頁面 → 首個關閉鍵 → 放開 | 首鍵先解除自身；視窗不附著時不按確定、不阻斷該鍵；放開後視窗重附著但已解除的首鍵反應不恢復 | E-12；[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07) |
| AC-21 | 等待時正常使用審閱注入；顯示訊息後正常點確定、再開與拖曳 | 工具可操作且不遮擋訊息確認；保留產品原有層級及位置；不可強制點擊或直接關閉替代操作 | E-12與測試工具隔離要求；[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07) |

## 9. 原型与前後端索引

[SCR-01.html](prototypes/SCR-01.html) 起始 ST-01；新增／刪除／匯出为產品控制；单一离线原型可到ST-02/03/04/05。独立「審閱工具」只注入旧契约合成响应、自訂訊息及条件政策；沒有真实业务算法、下載檔案或稽核写入。正式產品不会有注入控制。默认请求停在已知边界；选定目标的 拒絕且沒有逐列結果的回應僅揭露 TODO-02，不補出逐列結果；不会调用網路。審閱底部紀錄是工具，不是外部通知UI。浮水印、缺圖、原生警示的瀏覽器外觀、外部訊息呈現能力以及未確認的載入副作用无法展示；TODO-01/03/04/05/06/07。

BOUND-01/02 → [API-01/02](../../integration/AF-AFY10400/api-spec.md)；BOUND-03/04與拒絕回填→[HANDOFF-01..04](../../integration/AF-AFY10400/backend-handoff.md)。初始化操作已取得但沒有根頁前端事件或消費其初始化資料，不强加初始化API呼叫或日期／编辑控件；仅列介接未消费解释。
