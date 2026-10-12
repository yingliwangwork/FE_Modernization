# sourceCode-AF-AFY10100：翻新計劃

## 初始範圍

- 唯一根入口：`sourceCode/AF/AFY10100.jsp`；scope 由完整相對路徑建立。
- 建立於 2026-10-12T23:40:27.066890+08:00，在讀取入口內容與依賴分析之前。
- 納入：此入口的可證實畫面、互動、資料、跨邊界交接及責任拆解。
- 排除：其他入口內部行為、部署、發布、改寫原始 JSP。
- 啟動：`/legacy-to-spec jsp=sourceCode/AF/AFY10100.jsp auto=all`。
- DEC-01：使用者明確授權本 scope 所列 required 與 optional 工作；不代表外部依賴翻新或延後的決策。
- 未發現既有 scope、artifacts 或 config；採內建範本，雜湊見 [選用清單](template-selection.json)。

## 初始任務

| TASK | 類型 | 分類 | 順位 | 範圍與影響 | 依賴 | 完成與驗證條件 | 狀態 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TASK-01 | 共同工作 | required | 1 | 來源版本、編碼與依賴盤點 | 唯一入口 | 原始 bytes 雜湊、依賴清單、既有契約查找 | 執行中 |
| TASK-02 | 行為規格 | required | 2 | 本頁系統契約與案例 | TASK-01；依賴決策 | 每項已知事件與分支可追溯，未知局部標記 | 已選，待盤點 |
| TASK-03 | 視覺原型 | required | 3 | 本頁離線畫面與已知互動 | TASK-02 | 畫面與流程映射；不冒充外部能力 | 已選，待盤點 |
| TASK-04 | 元件樣式 | required（若有樣式） | 3 | DESIGN.md、實際載入 CSS | TASK-01、02；樣式依賴 | 值與狀態映射，瀏覽器核對 | 已選，待盤點 |
| TASK-05 | API 消費契約 | required（若有交換） | 2 | 精確交換與兩端映射 | TASK-01；後端基準 | 區分已確認與未知契約 | 已選，待盤點 |
| TASK-06 | 後端責任移交 | required（若未承接） | 2 | 有證據的後端責任 | TASK-01 | 承接或具體 HANDOFF/TODO | 已選，待盤點 |
| TASK-07 | 設計 tokens | optional | 3 | 額外 DTCG 樣式值與 CSS 映射 | TASK-04 | JSON 與實际值一致 | 已選，待盤點 |
| TASK-08 | 驗證 | required | 4 | 來源、文字、視覺、互動與連結 | 所選成果 | 執行紀錄與完整性限制 | 已選，待盤點 |

## 依賴與決策

待 TASK-01 盤點後補充；未取得決策的外部資源保持待決。

## 預期成果

`artifacts/design/sourceCode-AF-AFY10100/specification.md`、prototype、styles、元件 DESIGN；適用時建立 integration 文件與 tracking。尚未建立的文件不提供連結。

## TASK-01 盤點與依賴決策（分析後增補）

入口 SHA-256 `a539bd59d154a436b77f01466661601fd31825474454e52df949f7931ba5cee9`；2013 個原始物理行，全為 CRLF。BIG5 宣告與 cp950 嚴格解碼及中文字義相符；UTF-8 嚴格解碼失敗。原件未改，UTF-8 副本同一行號。Git 基準 `4ef5c093ecad200b454109fddaef2f4b168dfacd`。

搜尋工作區 `artifacts/`、`config/`、來源檔案清單與後端候選名稱：本輪前沒有交付契約或 config，未找到後端契約／Java 實作。來源有共用檔，但尚無適用轉換契約。

| DEP | 資源（來源引入位置） | 可取得／查找結果 | 本頁影響與停止邊界 | 決策／後續任務 |
| --- | --- | --- | --- | --- |
| DEP-01 | `/html/CM/header.jsp`，候選 `sourceCode/CM/header.jsp`（L3） | 有來源，未找到契約；執行路徑映射待核對 | 根路徑、tag、初始化、受信任情境、造字依賴 | 待決 DEC-02；TASK-09 |
| DEP-02 | `/html/CM/msgDisplayer.jsp`，候選 `sourceCode/CM/msgDisplayer.jsp`（L32） | 有來源，未找到契約 | 初始執行訊息、呈現分支與生命週期 | 待決 DEC-02；TASK-09 |
| DEP-03 | CM/js/ajax/prototype.js、CSRUtil.js（L21、23） | `sourceCode/CM/js/ajax/` 有來源，未找到契約 | 驗證請求的傳輸、解析、所有回呼及錯誤 | 待決 DEC-02；TASK-09 |
| DEP-04 | CM/js/HotKey.js、ui/validation.js、sortControler_ac.js（L24–26） | 有來源，未找到契約 | F2/F8/F9/F10、空值檢核、排序方向及色彩 | 待決 DEC-02；TASK-09 |
| DEP-05 | CM/js/calendar.js、date.js（L29–30） | 有來源，未找到契約 | 引入副作用與日期工具；根頁未見日期觸發控制 | 待決 DEC-02；TASK-09 |
| DEP-06 | `cssBase/cm.css`（L13）；候選 CM/css/cm.css 及變體 | 有候選，未找到契約；cssBase 未確認 | 全頁繼承、標題、表格、欄位、按鈕的最終樣式 | 待決 DEC-02；TASK-09 |
| DEP-07 | CM/border_01/02/03.gif、ecblank.gif、icon_dot11.gif（L378–434） | 本工作區檔名搜尋未取得圖片 | 裝飾邊框／查詢標記圖示，不能假造視覺等價 | 待決 DEC-02；TASK-09 |
| DEP-08 | AFY1_0100 查詢、檢核、取回、修改、刪除、明細服務（L94–140、315–369） | 未取得後端產物或可呼叫環境，部署狀態未確認 | 只還原本頁已知送出／消費；目標傳輸與業務承接待查 | 待決 DEC-02；TASK-05/06/09 |
| DEP-10 | 明細入口 `sourceCode/AF/AFY10100_detail.jsp` 候選 | 有來源，未找到契約；導向映射未確認 | 本 scope 只保留新視窗與傳遞；明細內部另開 scope | 待決 DEC-02；TASK-10 |

### 待決選擇

DEC-02：尚未取得外部依賴先翻新／延後的決策，`auto=all` 不自動決定。可獨立繼續根頁明示的結構、選列回填、取消、訊息原文與交接需求；共用詳細契約維持待決。

| TASK | 類型／分類 | 順位 | 範圍／影響 | 依賴 | 完成條件 | 狀態 |
| --- | --- | --- | --- | --- | --- | --- |
| TASK-09 | 外部依賴查證／required | 2 | DEP-01–08 支援本頁的有限共用契約與後端來源查證 | DEC-02；缺失檔案需取得 | 每項有適用契約及回查證據，否則局部 TODO | 待決，未授權擴大 |
| TASK-10 | 跨入口翻新／後續 scope | 另輪 | DEP-10 明細內部 | DEC-02；另開唯一入口 | 明細 scope 契約可引用 | 待決，不納入本 scope |

### 間接依賴補充

DEP-09：有限盤點 header L20–28、149–245、303、344 及 msgDisplayer L93–174 發現 CXL:csCommon、JSTL/cathay/input tag、全頁事件政策、水印、WIUtil 訊息顯示。宣告來源只作盤點，不展開未授權共用契約；資源映射、造字 parseEUDC、訊息元件實作與全域政策細節仍待查。DEP-09 與 DEP-01–08 一起已向使用者告知，DEC-02 待決；影響所有 ST、CMP、初始化 FLOW 與訊息呈現。取得明確選擇後才能執行 TASK-09。

## DEC-02 使用者決策

使用者回覆「先翻新支援本頁的共用依賴，明細頁延後」。授權DEP-01–09支援本頁的有限共用契約TASK-09；DEP-10明細內部延後TASK-10。圖片／後端／自訂tag缺少來源時仍保留缺口。日期工具嚴格UTF-8與cp950都失敗，先記錄編碼未知，不使用替換字元解碼。

## 最新任務類型與狀態（2026-10-13）

| TASK | 類型 | 分類 | 順位／依賴 | 影響與完成條件 | 執行狀態 |
| --- | --- | --- | --- | --- | --- |
| TASK-01 | 共同盤點 | required | 1／唯一入口 | 來源与依赖inventory、DEC-01/02完整 | 已完成 |
| TASK-02 | 行為規格 | required | 2／TASK-01/09 | specification、shared-contract、資料／分支／AC，局部TODO可回查 | 已建立已知部分；必要缺口開啟 |
| TASK-03 | 視覺原型 | required | 3／TASK-02/04/09 | 本頁结构与本地已知互动，未知停於交接；瀏覽器紀錄 | 已建立；部分驗證待最終紀錄 |
| TASK-04 | 元件樣式 | required | 3／TASK-01/02/09 | CMP-01–04 DESIGN與实际CSS，逐值/computed | 已建立已知與候選部分；TODO-02 |
| TASK-05 | API 消費契約 | required | 2／後端基準DEP-08 | 仅已确认API可投影；目前具體缺口索引 | 已建立缺口索引；正式契約阻塞，仍required |
| TASK-06 | 後端責任移交 | required | 2／來源证据 | HANDOFF-01–06，承接需後端基準 | 已建立；未承接TODO-04 |
| TASK-07 | 設計tokens | optional | 3／TASK-04 | DTCG所用色彩/px格式與映射，pt/%/公式明列未覆盖 | 已建立；格式核對待紀錄 |
| TASK-08 | 驗證 | required | 4／上述成果 | 根頁/共用本地操作、視覺与连結实际紀錄，真實环境不冒充 | 執行中；legacy/API环境仍缺 |
| TASK-09 | 共用依賴翻新 | required | 2／DEC-02已授權 | DEP-01–09相关条件契约；缺失实體/映射保留TODO | 可取得部分已建立；缺实体部分阻塞 |
| TASK-10 | 明細入口內部 | 後續scope | 另轮／DEP-10 | 单独入口计划與可引用明细契约 | 已延後，使用者DEC-02 |

auto=all解析后TASK-02–08全部已选，不再要求类型复选；TASK-09由DEC-02补充明确授权。未完成的required仍required。额外可選工作不是未經許可的第二个入口：取得后端/tag/字体/图片/date正确编码与运行环境后，继续对应TASK-05/08/09；明细TASK-10需另轮唯一入口。

DEP-11：CSR內MsgWin／遮罩、header水印库／字型／utility候选以及cm.css按钮背景图；DEP-12：底部框架候选bottom_css.htm、bottom.htm、sys_menu.jsp。它们支援DEC-02已经授权的header/消息/样式用法，不等同已确认部署；有限分析边界与hash在tracking。新发现来源不足逐项保留TODO-01/02/03/04，不能因先翻新选择而补造實體。

CHANGE-03／2026-10-13：浏览器发现序列化排序URL未触发，改为同参数onclick并停止锚点默认，已重新验证五栏排序。审阅区缩为左侧260px避免遮住原有中央消息窗；产品层级／位置／尺寸公式保持。检验键盘监听的案例加入移焦，区分一次性监听和按鈕原生Enter反应。

## 本輪結束狀態（2026-10-13）

已執行auto=all的本scope所有適用類型与DEC-02共用先翻新範圍，新增CMP-05條件水印／AC-26核對。TASK-02/03/04/06/07/08/09的可取得部分已交付與核對；TASK-05交付具體消費缺口索引，正式API契約仍受DEP-08阻塞；必要缺口TASK-09/08未視為完成。TASK-10明細內部按使用者決策已延後，沒有第二個根入口。

下一步依賴：取得csCommon/tag/parseEUDC/字型与圖片、实际cssBase/frame/工具與政策情境、date.js正確編碼、同版本後端基準与legacy執行資料後，先更新對應共用／API／HANDOFF，再回查所有受影響DATA/UI/ST/FLOW及AC。前述授權維持其明確範圍，取得資料前不得以沉默關閉TODO或宣告完整交付。詳細缺口与實測結果以[tracking](tracking.md)為準。
