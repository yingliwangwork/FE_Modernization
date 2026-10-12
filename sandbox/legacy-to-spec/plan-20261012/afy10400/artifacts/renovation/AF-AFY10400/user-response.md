已為唯一入口 `inputs/frontend/sourceCode/AF/AFY10400.jsp`（AF-AFY10400）完成首次計劃与有限依賴盤點，先建立計劃再讀取來源。入口共246行；提供材料只有這份JSP，沒有可重用依賴契約或後端基準。依 [legacy-to-spec skill](../../../skill/SKILL.md) 的「首次啟動停在此選擇關卡」規則，現在提供任務選單並維持待選。

計劃見 [plan](plan.md)，來源/缺口/檢查見 [tracking](tracking.md)。以下所有後續任務都尚未選中：

| TASK | 分類 | 順位与工作 | 前置/狀態 | 影響 |
| --- | --- | --- | --- | --- |
| TASK-02 | required | 1：根 JSP 已知畫面、列增刪、檢查/回填與流程規格 | 可先執行；缺共用内容留局部TODO，依賴决策保持待決 | specification 与 DATA/ST/FLOW/案例 |
| TASK-08 | required | 1：legacy 匯出/下載邊界与責任/移交 | 可先執行；不聲稱目標API已承接 | legacy 傳遞、顺序、HANDOFF/缺口 |
| TASK-09 | required（library適用性待查） | 1：入口/共用訊息本頁所需契約 | 待 DEC-02 與缺失來源 | 初始化/資源基底/受信任情境/訊息 |
| TASK-10 | required | 1：共用 CSS 与5圖片所需契約 | 待 DEC-03 與缺失來源 | 全頁生效樣式/邊框/圖像 |
| TASK-11 | required（未直接使用腳本的作用待查） | 1：8腳本的本頁使用鏈与相關副作用 | 待 DEC-04 與缺失來源 | 欄位序列化/回呼/錯誤訊息/下載/鍵盤生命週期 |
| TASK-03 | required | 1取得基準；TASK-02/08後完成API映射 | 阻塞：後端基準未提供；DEC-05待決 | 匯出/下載 wire、業務、授權与两端映射 |
| TASK-04 | required | 2：已知畫面/互動離線原型 | TASK-02後；相關共用呈現/腳本内容待決 | 視覺/互動/中間狀態 |
| TASK-05 | required | 2：元件DESIGN.md与實際CSS雙份 | TASK-02後；CSS/圖片等決策与材料未取得 | 樣式值/狀態/原型載入一致 |
| TASK-06 | required | 3：所選产物覆盖/引用/互動與適用介接驗證 | 所選產物完成後；尚無契約/原型 | tracking、實際驗證、部分/完整判定 |
| TASK-07 | optional | 3：DTCG tokens | TASK-05後；可额外选择 | 額外可攜樣式值，不取代必要CSS |

TASK-01（required，順位0，首次計劃/盤點）已依啟動授權完成。每項完成條件与驗證方法详见plan。

未取得的依賴请分别選「先翻新所需部分」或「延後」；先翻新仍需提供材料，不能填猜測：

- DEC-02：DEP-01/11/19，`/html/CM/header.jsp`、`/html/CM/msgDisplayer.jsp`、`ListOrderedMap` 匯入线索。入口情境/資源值、初始化訊息与library适用性未确认。
- DEC-03：DEP-02/12～16，`cm.css`、`border_01.gif`、`border_02.gif`、`border_03.gif`、`ecblank.gif`、`icon_dot11.gif`。影響全頁最終生效樣式、邊框、留白与面板圖像。
- DEC-04：DEP-03～10，`prototype.js`、`CSRUtil.js`、`PageUI.js`、`HotKey.js`、`Validator.js`、`RPTUtil.js`、`calendar.js`、`date.js`。欄位序列化、回呼分流、共用錯誤訊息/例外与下載語意未知，部分脚本載入副作用待查。
- DEC-05：DEP-17/18，legacy `AFY1_0400` 匯出与下載。後端 path/method/schema、業務/授權/檔案、承接与部署未確認；可選「提供基準後先核對」或「本輪延後目標API」。

可先回 `TASK-02`、`TASK-08` 或明確一組任务，另附 DEC-02～05 的選擇。建議先做 TASK-02 与 TASK-08 的本地已知部分；這不表示同意延後依賴。沒有答案時保持待選/待決。

本次13項計劃靜態檢查通過，報告見 [checks.json](checks.json)。只執行來源 metadata、靜態盤點與文件/連結檢查；没有执行JSP或後端，也未生成行為規格、API、移交、原型或CSS。尚未確認的共用/後端行为维持未知。
