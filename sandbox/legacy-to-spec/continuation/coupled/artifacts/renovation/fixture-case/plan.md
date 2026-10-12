# fixture-case：翻新計劃

建立日期：2026-10-12。此文件先於任何來源／依賴內容分析實際建立。首次版本 0.1，建立順序 P0；本輪版本 0.2，續作沿用記錄。

唯一入口：`inputs/frontend/Case.jsp`，manifest SHA256 `90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154`。Scope 使用 manifest 明訂 `fixture-case`，本案例無其他 scope 交付。初始納入入口呈現、可辨識事件與邊界交換；依賴待盤點。排除其他入口翻新、後端修改、真實網路及 legacy 執行。

工作順序：P0 計劃 → P1 依賴盤點與既有契約適用性核對 → P2 套用 task.txt 明確沙盒模擬決策 → P3 入口設計／視覺／API 投影／責任移交 → P4 驗證與獨立追蹤。

[設計](../../design/fixture-case/specification.md) · [追蹤](tracking.md)

## 任務與影響

| 任務 | 工作／依賴 | 影響與交付 | 完成條件／驗證 | 狀態 |
| --- | --- | --- | --- | --- |
| TASK-01 | 盤點根來源依賴；依賴 P0 | 入口呈現、互動與所有邊界 | 每一引入資源有定位、停止邊界、可取得性 | 完成盤點 |
| TASK-02 | 搜尋 inputs/specs/；依賴 TASK-01 | 共用依賴契約引用／TODO 位置 | 核對版本、條件與行為，不合適者列缺口 | 完成適用性核對 |
| TASK-03 | 指定後端基準并分析混合責任；依賴 TASK-01 | LOGIC、API、HANDOFF | 每片段逐項責任歸屬与承接證據 | 完成分類；承接缺口開啟 |
| TASK-04 | 系統契約與离線原型；依賴 TASK-02、TASK-03 | artifacts/design/fixture-case/ | 來源覆蓋、狀態與分支一致；缺口有 TODO | 部分契約／原型已交付 |
| TASK-05 | 介接與後端移交；依賴 TASK-03 | artifacts/integration/fixture-case/ | 精確投影既有操作，未承接能力不造端點 | 已知投影／移交已交付 |
| TASK-06 | 適用驗收與追蹤；依賴 TASK-04、TASK-05 | tracking.md、檢查紀錄 | 靜態、連結、原型檢查；未執行如實記錄 | 本輪重新驗證；限制見 tracking |

## 依賴查找與決策

P0 歷史初始狀態：當時尚未分析來源依賴；目前盤點結果見 P1/P2 更新。查找只限本案例提供的 inputs/，不可取得內容保持未知。

<a id="dec-01"></a>DEC-01：task.txt 明訂「reuse suitable existing contracts; defer every dependency lacking a suitable contract」。只適用此沙盒的模擬使用者決策；不代表正式專案允許延後，不將未回覆或推測記為授權。盤點後逐項記錄受影響契約位置、後續取得資料與重新驗證工作。

## 變更

CHANGE-00：P0 首次建立計劃；尚未分析来源依賴。

## P1/P2 更新：依賴、查找結果與決策

CHANGE-01，2026-10-12：在P0實際落盤後才讀取本案例inputs。搜尋範圍為manifest列出的inputs/specs/唯一文件action-bar.md與指定後端兩份文件，未查看其他案例／正式專案。未找到仅表示此输入范围内未取得。所有provided snapshots雜湊匹配manifest。DEC-01逐项套用如下。

| DEP | 資源与查找／適用性 | 影響及停止邊界 | 決策与後續 |
| --- | --- | --- | --- |
| DEP-01 | inputs/frontend/components/action-bar.jspf；inputs/specs/action-bar.md的fixture-component-v1源雜湊完全匹配、一个按钮与回调职责符合 | CMP-01、UI-04、FLOW-02；只核对本页按钮，不改寫共用定义 | 重用CMP-SEARCH-ACTION；DEC-02、TASK-02完成 |
| DEP-02 | inputs/frontend/styles/base.css；specs中没有适用契约 | SCR-01、CMP-02、UI-05、AC-11；仅盘点本页4条明确CSS，不另生成依赖契约 | 沙盒延后；TODO-06／TASK-07 |
| DEP-03 | inputs/frontend/legacy-bridge.js；没有适用共用传输契约 | FLOW-02／03、BOUND-02；只核对直接查阅传输与是否有回應处理，不扩展成bridge翻新 | 沙盒延后；TODO-06／TASK-07；目标传输由指定API定义 |
| DEP-04 | inputs/backend/api-contract.md，fixture-v1；inputs/backend/business-rules.md同版语意补充；明确承接searchRows | API-01、BOUND-02、DATA-01／03／04／08；只消费查阅操作 | 重用已有目标服务契约；DEC-02；缺项分别TODO-02／04，TASK-09 |
| DEP-05 | example.Ledger／Ledger.store，未提供实现或适用契约 | LOGIC-07、FLOW-05、BOUND-03；仅保留调用及参数，不猜存储机制 | 沙盒延后；TODO-03／TASK-08 |
| DEP-06 | 受信任名称与单位情境，未提供独立目标初始化／提交契约 | FLOW-01／05、UI-02、DATA-02／08；不读取外部session系统 | 名称TODO-01；数量单位TODO-03；查阅单位由API已定义服务端来源；TASK-08 |
| DEP-07 | legacy查阅路径／响应者，未提供旧服务契约或实现 | FLOW-03、BOUND-02；不查询真实服务，已知反应只来自前端 | 沙盒延后；TODO-04／TASK-09；目标适用部分仍重用API-01 |

<a id="dec-02"></a>DEC-02：DEP-01与DEP-04有适用契约，依task.txt模拟决策重用。DEP-02／03／05／06／07和DEP-04缺项均按DEC-01沙盒延后；正式项目尚无延后授权，不将此纪录复制为正式决定。缺口已经在对话告知，以本案例提供的预设决定继续，没有新增确认门槛。

## 後續任務

### TASK-07

取得DEP-02／03适用共用契约或另开受控依赖翻新范围，先核對版本／入口实际用法，再更新CMP-02、FLOW-02／03及原型视觉／传输说明，重新验证AC-02～06、AC-10／11。依赖：新的契约及正式决策。影响：仅本入口使用位置。完成条件：TODO-06缺失契约可定位，回查样式与事件，必要浏览器检查通过。状态：延后，TODO-06。

### TASK-08

取得可信初始化与数量业务／Ledger承接资料，先核对名称读取、模式选择、整数解析、门槛计算、单位取得、写入、渲染顺序及异常，再更新HANDOFF-01／02、BOUND-01／03、相关DATA与API投影，验证AC-01／07～09。依赖：后端承接资料及错误／交易保障确认。影响：UI-02、FLOW-01／04／05。完成条件：合法来源、完整分支、真实承接与必要验证。状态：延后，TODO-01／03。

### TASK-09

取得目标排序提示、認證、错误、空值及可呼叫环境契约，先核对未承接字段与目标结果，再更新HANDOFF-03、API-01、BOUND-02、FLOW-03，验证AC-02～06／10；禁止自造排序字段或通用错误文案。依赖：后端目标契约与确认。影响：UI-05、ST-03／08。完成条件：字段／结果合法来源、两端一致与介接检验。状态：延后，TODO-02／04。

### TASK-10

取得受控浏览器与必要legacy观察环境／测试资料（本案例禁止legacy执行），进行实际离线prototype渲染、原生警示、键盘／焦点、浏览器控制台与连线检查；在授权的后续范围观察legacy作视觉比对。依赖：可用环境与新范围授权。影响：SCR-01、AC-01～11。完成条件：可重现操作结果及截图／日志，不以DOM模拟取代视觉证据。状态：未完成，TODO-05。

## P3/P4 任务状态

TASK-01完成：根入口所有60行与直接依赖定位已盘点。TASK-02完成：仅DEP-01有适用共用前端契约，其余按模拟决定延后。TASK-03完成：LOGIC-01～13分类并核对目标承接，缺口未关闭。TASK-04完成部分契约／原型文件。TASK-05完成已知API投影与三个移交需求，不代表服务已承接。TASK-06已执行静态与原型脚本检查；浏览器、legacy与真实介接未执行，见tracking。后续任务未完成不隐藏。无扩充第二个入口、无写入inputs或skill。

CHANGE-02：根据耦合差距增补TASK-07～10与6个TODO；实际结果见[tracking](tracking.md#7-验证与交付判定)。


## 續作計劃（版本 0.2）

CHANGE-03，2026-10-12：先讀 task、manifest、目前 skill、既有 plan／tracking／契約；沿用唯一入口、E-01～15、DEP-01～07、DEC-01／02、TASK-01～10、TODO-01～06。上述 P0/P1 及 V-01～06 為 0.1 歷史紀錄；本輪不重新聲稱建立首次計劃。來源及依賴版本須重新核對，歷史通過不作本輪證明。下列續作任務於本輪修訂前登錄。

### TASK-11

依賴：task／manifest／skill 快照、既有 0.1 契約與追蹤。影響：DATA／ST／UI／FLOW／BOUND／CMP 的缺口位置、API-01 案例及全部交付引用。順序：核對快照與既有 ID → 回查依賴版本／本頁用法 → 修訂缺口標記及 API wire 案例 → 展開逐 ID 實際位置表 → 重跑靜態與原型互動檢查。完成條件：版本核對結果、實際 TODO 錨點與 TASK／DEC 可解析、每項 API 案例有獨立前置／事件／預期、必要本地檢查留存新結果；無法執行者明示限制。狀態：完成本輪可處理範圍；既有後續 TASK-07～10 不因此完成。核對記錄及實際重跑結果見 [tracking 第10節](tracking.md#revision-02-verification)。

CHANGE-03：0.2 續作完成 TASK-11；原始快照、依賴基準及既有決策保持相同，新增位置核對與 API wire 案例；必要後端承接與瀏覽器驗證仍缺，部分交付。對 0.1 legacy 執行限制文字的更正見 tracking 第10節。
