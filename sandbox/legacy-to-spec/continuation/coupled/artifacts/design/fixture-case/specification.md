# 項目查閱：前端系統設計規格

契約版本：0.2，scope：`fixture-case`。部分契約；來源與驗證見 [追蹤](../../renovation/fixture-case/tracking.md)，工作與依賴決策見 [計劃](../../renovation/fixture-case/plan.md)。[原型](prototypes/items.html)。

## 1. 目的與系統邊界

INT-01：使用者啟動關鍵字查閱，看到項目代碼、名稱、排序提示或已有的無項目／拒絕訊息。這是已證實的操作能力；更廣的業務目的未由材料說明，不從畫面名稱推導（E-03、E-05）。

本契約納入單一項目查閱畫面的生命週期、查閱、數量送出、共用查閱動作用法及可見回應。單位情境、授權、業務計費及儲存由服務責任承擔。另一入口、整個共用資源契約、真實交易與部署不在本契約邊界。

| 缺口 | 受影響內容 | 追蹤 |
| --- | --- | --- |
| 審閱者名稱的合法目標來源、空值與讀取異常 | FLOW-01、UI-02、DATA-02、BOUND-01 | [TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| 查閱缺排序提示輸出 | FLOW-03、UI-05、DATA-05、BOUND-02 | [TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |
| 數量計費、單位情境、寫入與例外未承接 | FLOW-04、FLOW-05、BOUND-03 | [TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| 認證、未定義結果／傳輸失敗反應、操作環境 | FLOW-02、FLOW-03、BOUND-02 | [TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |
| 未取得執行畫面、焦點、鍵盤及瀏覽器視覺驗證 | SCR-01、所有 UI、AC | [TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| 共用樣式／查閱傳輸資源無適用獨立契約 | SCR-01、CMP-02、FLOW-02、FLOW-03 | [TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |

## 2. 觸發者與情境

ACT-01：使用者可輸入關鍵字、啟動查閱、輸入數量並送出。來源無前端角色門檻，不代表服務端無授權（E-03～E-06）。ACT-02：入口生命週期帶入審閱者情境及數量提交模式；ACT-03：查閱服务回應觸發結果重建（E-01、E-02、E-05）。

首次进入时，系统先取得審閱者名稱；若此入站事件选择数量提交，先处理数量业务，再生成画面。正常生成的关键字、状态与结果列均为空，数量输入为空。名称由受信任情境提供，使用者不可任填（E-01、E-02、E-03、E-06）。必要目标来源未知：[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)、[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)。

## 3. 資料語意與邊界

| ID | 語意、概念型別与來源 | 條件与生命週期 | 證據 |
| --- | --- | --- | --- |
| DATA-01 | 關鍵字，文字，UI-03 使用者輸入 | 输入上限12；送出时去除首尾空白；空字串是不指定关键字 | E-03、E-04、E-09 |
| <a id="data-02"></a>DATA-02 | 審閱者名稱，文字，受信任情境 | 初始化讀取并显示；空值／合法目标来源未知：[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) | E-01、E-03 ；缺口：[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| DATA-03 | 項目代碼，文字，服務結果 | 每次回應先移除所有舊列，再按回應集合順序顯示 | E-05、E-10 |
| DATA-04 | 名稱，文字，服務結果 | 与 DATA-03 同列，不从名称另推含义 | E-05、E-10 |
| <a id="data-05"></a>DATA-05 | 排序提示，来源值型别未定义 | legacy 第三栏直接显示；目标尚无来源：[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) | E-05、E-11 ；缺口：[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |
| <a id="data-06"></a>DATA-06 | 數量，输入文字；业务处理需整数 | 前端只阻断精确空字串；后端整数解析规则与异常需承接 | E-06、E-02 ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| <a id="data-07"></a>DATA-07 | 費用，业务整数结果；货币与单位未定义 | 数量≥4时乘8，否则乘10；只用于写入，不新增画面字段 | E-02 ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| <a id="data-08"></a>DATA-08 | 单位识别，受信任服务情境 | 查阅由服务端取得；数量写入原有受信任来源尚未承接 | E-02、E-09、E-12 ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |
| <a id="data-09"></a>DATA-09 | 提交模式，内部动作选择，非可见字段 | 数量送出携带固定提交意图；不可把它做成用户选择器 | E-02、E-06 ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |

| 邊界 ID | 觸發／傳入／結果 | 責任界線及可見效果 |
| --- | --- | --- |
| <a id="bound-01"></a>BOUND-01 | FLOW-01 取得 DATA-02 | 名称初始化先于数量业务，之后由 UI-02 显示；[HANDOFF-01](../../integration/fixture-case/backend-handoff.md#handoff-01)，[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) ；缺口：[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| <a id="bound-02"></a>BOUND-02 | FLOW-02 送出 DATA-01；FLOW-03 收到结果与资料集合 | 服务端判断单位权限；已确认的成功、无项目、拒绝结果映射见 [API-01](../../integration/fixture-case/api-spec.md#api-01)。排序提示 [TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；认証／其他回应 [TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；共用传输契約 [TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) ；缺口：[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |
| <a id="bound-03"></a>BOUND-03 | FLOW-04 携带 DATA-06、DATA-09，FLOW-05 使用 DATA-08 | 运算与写入由后端承接；不调用查阅操作替代提交，不以本地运算伪装成功。[HANDOFF-02](../../integration/fixture-case/backend-handoff.md#handoff-02)、[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |

## 4. 畫面與操作體驗

<a id="scr-01"></a>SCR-01「項目查閱」。順序：标题 → 審閱者 → 關鍵字 → 共用查閱動作 → 状态段落 → 三栏结果表 → 数量表单。没有其他导航或取消控件证据（E-03、E-06）。 視覺驗證 [TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；共用樣式 [TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07)。

| UI ID | 标签／显示内容 | 条件与事件 | 证据／缺口 |
| --- | --- | --- | --- |
| <a id="ui-01"></a>UI-01 | 項目查閱 | 页标题与主标题，无操作 | E-03 ；缺口：[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ui-02"></a>UI-02 | 審閱者：＋DATA-02 | 初次生成；不可编辑 | E-01、E-03；[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) ；缺口：[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ui-03"></a>UI-03 | 關鍵字＋文字输入 | 无必填；输入上限12；值改動沒有已定義查閱事件 | E-03 ；缺口：[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ui-04"></a>UI-04 | 查閱 | 始终显示；未定义禁用条件；触发 FLOW-02 | E-07、E-13 ；缺口：[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ui-05"></a>UI-05 | 表头依次「項目代碼」「名稱」「排序提示」 | FLOW-03 重建资料列；无行选择／排序按钮 | E-03、E-05；第三栏 [TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) ；缺口：[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |
| <a id="ui-06"></a>UI-06 | 状态段落 | 初始空；查阅开始清空；特定回應显示 MSG-01／02 | E-03、E-04、E-05 ；缺口：[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ui-07"></a>UI-07 | 數量＋文字输入 | 无最大长度／最小值／步进／数字输入限制证据；精确空值由 BR-03 阻断 | E-06 ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ui-08"></a>UI-08 | 送出數量 | 数量表单提交触发 FLOW-04，后续后端缺口 | E-06；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |

已确认的视觉事实：无衬线字体，内容最大宽720px，页边距24px，文字色#222；表格100%宽、上下16px间距，边框合并、#555单像素边框、单元格6px内距、左对齐；查阅区上方8px间距（E-08）。这些是入口使用时可见的源定义，不声称其他页面通用样式已翻新。CMP-02 共用视觉依赖契约：[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07)。响应式断点、实际像素效果、焦点恢复、额外键盘快捷键未确认：[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)。

CMP-01：重用 [fixture-component-v1 / CMP-SEARCH-ACTION](../../../inputs/specs/action-bar.md#cmp-search-action)，來源雜湊已核對（E-07、E-13）。本頁將其啟動事件連到 FLOW-02；查阅内容、状态与结果由本頁负責。该契约不定义结果或禁用策略，不另造共用组件规范。

<a id="cmp-02"></a>CMP-02：入口使用的共用視覺資源。本頁僅保留已定位的樣式事實（E-08），獨立契約未取得；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07)。；缺口：[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07)。

## 5. 状态與轉移

| 状态 | 条件／可见内容 | 资料 |
| --- | --- | --- |
| <a id="st-01"></a>ST-01 | 正常首次生成，UI-06 与资料列空白 | 输入为空，審閱者来自情境 ；缺口：[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="st-02"></a>ST-02 | 查阅已发出，尚未收到回應 | UI-06 已清空，旧资料列仍保留；输入与按钮未禁用 ；缺口：[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |
| <a id="st-03"></a>ST-03 | 成功回應 | 三栏集合；第三栏目标资料有缺口，不因此删除已知列结构 ；缺口：[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="st-04"></a>ST-04 | 无项目回應 | 资料列空，UI-06 显示 MSG-01 ；缺口：[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="st-05"></a>ST-05 | 不允许回應 | 资料列空，UI-06 显示 MSG-02 ；缺口：[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="st-06"></a>ST-06 | 空数量提交被阻断 | 原生警示 MSG-03；确认后原画面资料保持 ；缺口：[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="st-07"></a>ST-07 | 非空数量已交接 | 不新增成功状态；后端完成／异常待承接 ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="st-08"></a>ST-08 | 回應结果非已识别三类 | 资料列清空，不添加通用讯息；状态段落保持该回應发生前的值 ；缺口：[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |

| TR | 转移、条件与结果 | FLOW／证据 |
| --- | --- | --- |
| TR-01 | 任意已生成状态 → ST-02；清空状态，不提前清资料列 | FLOW-02、E-04 |
| TR-02 | 可接收回應状态 → ST-03；先清资料列，再按集合顺序填入 | FLOW-03、E-05 |
| TR-03 | 可接收回應状态 → ST-04；清资料列、显示「沒有項目」 | FLOW-03、E-05 |
| TR-04 | 可接收回應状态 → ST-05；清资料列、显示「不允許查閱」 | FLOW-03、E-05 |
| TR-05 | 数量精确空字串 → ST-06；警示并阻断；关闭恢复原画面 | FLOW-04、E-06 |
| TR-06 | 数量非空 → ST-07；允许交接，无新增前端数字判断 | FLOW-04、E-06 |
| <a id="tr-07"></a>TR-07 | 其他 legacy 结果 → ST-08；清资料列、不改状态文案 | FLOW-03、E-05；目标结果合法性 [TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) ；缺口：[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |

ST-03 的查阅回應处理不会主动清除此前由另一回應写入的状态文案。并发回應按实际到达顺序处理，未定义取消／最新请求优先或防重入机制（E-04、E-05）。

## 6. 規則与訊息

BR-01：查阅发出前先清空状态，再读取并去除关键字首尾空白；不验证非空（E-04）。BR-02：每次查閱回應都先清旧资料列；成功按回應集合顺序填三列，无项目／拒绝时改状态文案；成功分支不再次清状态（E-05）。BR-03：只当数量值为精确空字串才原生警示并阻断；空白、负数、非数字均未由此前端检查阻断，不代表后端接受这些值（E-06）。<a id="br-04"></a>BR-04：數量提交事件的业务处理先解析整数，再以≥4为门槛计算费用，最后带受信任单位写入；目标后端未承接（E-02；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)）。BR-05：目标查阅由服务端单位情境判断权限，不允许→拒绝；允许且无数据→无项目；允许且有数据→成功（E-12）。

| MSG | 原文与触发 | 位置／关闭后反应 |
| --- | --- | --- |
| MSG-01 | 沒有項目；无项目回應 | UI-06，同页保留至下一次查阅开始或其他回應改写 |
| MSG-02 | 不允許查閱；拒绝回應 | UI-06，同页保留至下一次查阅开始或其他回應改写 |
| MSG-03 | 數量不得為空；精确空数量提交 | 原生警示；确认后不送出，原画面資料保持 |

三条原文均由 E-05／E-06 支撑；不使用后端通用成功或失败文字替换。

## 7. 触发流程

### FLOW-01：进入并生成画面 <a id="flow-01"></a>

缺口：[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)。

ACT-02 入站事件触发；前置为尚未生成画面。先取得 DATA-02（BOUND-01），然后若为数量提交模式执行 FLOW-05，正常继续时按 SCR-01 顺序生成画面（ST-01）。读名称在业务计算前；正常非提交不计算或写入（E-01、E-02、E-03）。名称来源／异常 [TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；提交异常对渲染影响 [TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)。

### FLOW-02：使用者启动查阅 <a id="flow-02"></a>

缺口：[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07)。

ACT-01 激活 CMP-01／UI-04；前置为画面已生成，允许重复操作。步骤：1 清 UI-06；2 读取 UI-03 并去首尾空白；3 以 DATA-01 交接 BOUND-02；4 等待，ST-02 中旧资料列保持，按钮不被禁用（E-04、E-07）。重复启动不取消旧请求，也不添加防抖。共用传输契约未建立 [TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07)；認證及失敗反应 [TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)。

### FLOW-03：收到查阅回應 <a id="flow-03"></a>

缺口：[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07)。

ACT-03 每次回應触发，与发出先后无已证实优先关系。步骤：1 先清除所有旧列；2 判结果；3 成功依集合顺序显示 DATA-03、04、05（TR-02）；无项目显示 MSG-01（TR-03）；拒绝显示 MSG-02（TR-04）；其他 legacy 结果不新增文案（TR-07）。成功分支保持回應前状态文案，不能以显示方便改成每次回應清空（E-05）。

目标成功缺 DATA-05 [TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)，所以原型使用合成的已知 legacy 列形状展示第三栏；这不证明 API 支持该字段。集合缺失／格式异常、传输失败、目标未知结果 [TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)。

### FLOW-04：使用者送出数量 <a id="flow-04"></a>

缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)。

ACT-01 提交 UI-08 所属表单；可使用 UI-07 当前值。先比较精确空字串：空→MSG-03 原生警示，阻断发送，确认后保留原画面资料（TR-05）；非空→允许 DATA-06 与内部提交意图 DATA-09 交接 BOUND-03（TR-06）（E-06）。没有计算费用、结果提示、确认对话或第二个提交目的地的前端证据。提交边界 [TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；原型非空在审阅层停于已知边界。

### FLOW-05：数量提交的业务处理 <a id="flow-05"></a>

缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)。

ACT-02 收到数量提交模式，且 FLOW-01 已先捕捉名称。依次：解析 DATA-06 为整数 → 数量≥4费用为数量×8，否则数量×10 → 以 DATA-08、整数数量及费用写入 → 正常继续生成 SCR-01（E-01、E-02）。非提交模式直接跳过此业务分支。运算与写入不由前端承担；[HANDOFF-02](../../integration/fixture-case/backend-handoff.md#handoff-02)、[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)。解析失败、写入失败、原子性、回滚、重送均未有足够契约，不造成功路径或客户端补偿。

## 8. 行为驗收案例定义

| AC | 前置／操作 | 具体预期／范围 |
| --- | --- | --- |
| <a id="ac-01"></a>AC-01 | 正常非提交进入，可信名称为合成「示例審閱者」 | SCR-01 顺序；输入、状态、结果空；显示名称；不写入；E-01～03 ；缺口：[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ac-02"></a>AC-02 | 旧列与状态已有内容，关键字「  示範  」；点查阅 | 状态立即空，旧列仍在，交接关键字「示範」，按钮未禁用；E-04 ；缺口：[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |
| <a id="ac-03"></a>AC-03 | 接收成功与两笔合成完整 legacy 资料 | 先清旧列，显示两行三栏，集合顺序保持；目标排序提示待 TODO-02；E-05 ；缺口：[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |
| <a id="ac-04"></a>AC-04 | 回應无项目 | 所有资料列清空，精确显示「沒有項目」；E-05、E-10 ；缺口：[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |
| <a id="ac-05"></a>AC-05 | 回應拒绝 | 所有资料列清空，精确显示「不允許查閱」；E-05、E-10 ；缺口：[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |
| <a id="ac-06"></a>AC-06 | 两次查询未完成；先回應无项目，后回應成功 | 第二回應生成结果列，状态仍是「沒有項目」；不按最新启动顺序丢弃回應；E-04、E-05 ；缺口：[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |
| <a id="ac-07"></a>AC-07 | 数量精确空字串；送出并确认警示 | MSG-03 原文，阻断交接；输入与查阅结果保持；E-06 ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ac-08"></a>AC-08 | 数量分别「3」「4」「-1」「abc」「 」 | 前端非空均允许交接；业务整数3费用30、4费用32、-1费用-10来自legacy，非法解析结果未知；原型不运算；E-02、E-06、TODO-03 ；缺口：[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ac-09"></a>AC-09 | 非提交模式／提交模式，合成受信任单位 | 前者不写；后者名称捕捉→整数解析→计费→写入→生成，顺序不可更改；目标验证待 TODO-03 ；缺口：[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10) |
| <a id="ac-10"></a>AC-10 | 接收其他 legacy 结果，原状态含 MSG-02 | 清资料列，原状态保持，无新增通用文案；目标其他结果未知；E-05、TODO-04 ；缺口：[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |
| <a id="ac-11"></a>AC-11 | 原型首次生成、各结果状态及空值警示 | 样式只核对 E-08 的明示属性；浏览器／像素／焦点检验待 TODO-05 ；缺口：[TODO-05](../../renovation/fixture-case/tracking.md#todo-05) · [TASK-10](../../renovation/fixture-case/plan.md#task-10)；[TODO-06](../../renovation/fixture-case/tracking.md#todo-06) · [TASK-07](../../renovation/fixture-case/plan.md#task-07) |

## 9. Prototype 索引

| 原型 | SCR／ST／FLOW | 进入方法、数据与限制 |
| --- | --- | --- |
| [items.html](prototypes/items.html) | SCR-01；ST-01～08；FLOW-01～04 的可见部分 | 打开为 ST-01；点查閱进入 ST-02，审阅工具选择一个待回應再注入成功／无项目／拒绝／其他结果；选择任意待回應可展示交错。空数量显示原生警示；非空停于审阅边界。名称与第三栏为显式合成资料；不模拟 FLOW-05 运算／写入，不调用目标服务，不证明真实初始化、排序提示、認證或部署。審閱工具可隐藏，不属于产品功能。 |

## 10. 前後端契約索引

| 邊界 | 前端需求 | 契約 |
| --- | --- | --- |
| BOUND-01／DATA-02 | FLOW-01、UI-02 | [HANDOFF-01](../../integration/fixture-case/backend-handoff.md#handoff-01)，E-01＋E-11，TODO-01 |
| BOUND-02／DATA-01、03、04、08 | FLOW-02、FLOW-03 | [API-01](../../integration/fixture-case/api-spec.md#api-01)，E-04／05＋E-09／10／12；認證 TODO-04 |
| BOUND-02／DATA-05 | 第三栏显示 | [HANDOFF-03](../../integration/fixture-case/backend-handoff.md#handoff-03)，E-05＋E-11，TODO-02 |
| BOUND-03／DATA-06～09 | FLOW-04、FLOW-05 | [HANDOFF-02](../../integration/fixture-case/backend-handoff.md#handoff-02)，E-02／06＋E-11／12，TODO-03 |

