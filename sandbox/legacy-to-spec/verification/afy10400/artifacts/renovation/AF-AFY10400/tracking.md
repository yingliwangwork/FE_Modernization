# AF-AFY10400：翻新執行與持續追蹤

[先行plan](plan.md)；[系統規格](../../design/AF-AFY10400/specification.md)；[support-v1.1](../../design/AF-AFY10400-support/contract.md)；[API投影](../../integration/AF-AFY10400/api-spec.md)；[HANDOFF](../../integration/AF-AFY10400/backend-handoff.md)。分析日期2026-10-12，Codex；v1首次。部分交付：必要相容／環境／依賴契約仍未知，未進行正式介接或legacy視覺比較。

## 來源與邊界

唯一根 JSP：`inputs/frontend/sourceCode/AF/AFY10400.jsp`；SHA-256 `fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a`。BIG5宣告，原bytes可完整CP950解碼，CRLF，共246行。所有行號基於原來源；解碼只在記憶體中、不改輸入，不插刪行。UTF8初讀亂碼不作標籤證據，轉CP950後取得原文。

每個依賴完整雜湊、逐檔 strict decoding 結果、byte-line 行數與行尾見 [source-inventory.json](source-inventory.json) 及 [source-byte-result.json](checks/source-byte-result.json)，全部與本輪manifest比對。date.js 是未確認編碼：1,089 原始 byte-lines、1,088 CRLF，strict CP950/Big5/Big5-HKSCS 首次失敗 offset40（原始第3行開頭註解、hex 8e cd），strict UTF-8 失敗 offset8（第2行）。不再聲稱 UTF-8／完整CP950可讀，不猜破損註解；僅原始 bytes 分行／ASCII符號檢索、不使用 replacement decode，也不從它推導產品標籤或日期功能。其他已採用 codec 的完整嚴格解碼均通過，但成功不證明唯一預期編碼。後端root=`inputs/backend`，指定OPENAPI SHA-256 `13307ed1144946124179d6e02148999e64783e031d440aacc8ff54e03c32f1ef`、2026-08-12、0.0.1-SNAPSHOT，文件宣告Controller/DTO盤點與預設stub。未提供可呼叫環境、部署狀態未確認。

納入主頁生命週期、所有三個handler與回應、兩個include必要片段、交換/下載/訊息/政策工具；停止於未提供tag、功能設定/登入服務、底欄、WIUtil、圖像/字體/浮水印、FileDownload adapter。未轉其他JSP全頁，未執行legacy/後端/網路、未讀其他trial/parent reports。所有輸出僅artifacts。

## 計劃執行索引

| TASK/DEC | 實際順序及結果 | 交付／待辦 |
|---|---|---|
| TASK-01 | 先寫plan，才讀root及依賴；查inputs/specs未提供、manifest/backend材料；不是搜尋全workspace | DEP-01–11與CHANGE-01 |
| DEC-01 | 沿用task.txt sandbox明示模擬：重用適用；先轉必要可用；不可取得延後 | 不需要將未回覆當授權；未授權正式擴scope |
| TASK-02 | 必要片段support-v1先於root specification寫出 | CMP-01–07；TODO-01/02/04 |
| TASK-03 | 主規格及SCR-01離線HTML，合成回應屬審閱層 | FLOW-01–09；無後端演算法 |
| TASK-04 | 已有export/download投影；prompt全部字段記錄未消費；不自造endpoint | API-01/02、HANDOFF-01–04；TODO-03/05 |
| TASK-05 | 實際靜態語法、連結、原件雜湊核對，prototype本機模擬檢查 | V紀錄如下，瀏覽器/legacy限制TODO-06 |
| TASK-06–09 | 所需外部資料／瀏覽器待補 | 見TODO各項及plan，不能宣告完整 |

## 證據登錄

下表相對於`inputs/frontend/sourceCode/`的路徑，後端例外列全路徑；版本由source-inventory SHA-256鎖定。摘錄只支撐靜態契約，不是執行觀察。

| E | 原件／原始行號或穩定符號 | 最小事實／支撐 | 限制 |
|---|---|---|---|
| E-01 | AF/AFY10400.jsp:1–31、128、188–223 | BIG5、include/scripts、initApp unique_num=0/tb1/displayMessage，無資料列 | FLOW-01/ST-01；不證明部署執行 |
| E-02 | AF/AFY10400.jsp:22–65、116–123 | 唯一遞增、最後附空列、10字ID、3×30保單、delete無confirm、重配色 | FLOW-02/03，無後端delete |
| E-03 | AF/AFY10400.jsp:67–113 | 空值→後方duplicate順序；Form.serialize不是param；success/failure都rtnMap回填，success才download | FLOW-04/05/BR/MSG；目標能力需E-12 |
| E-04 | AF/AFY10400.jsp:129–245 | 雙標題、畫面號、說明、選项L/R、AT/BG/CB、三列静态頭、export | SCR/UI/INT；文件意圖不證明副作用 |
| E-05 | CM/css/cm.css:BODY、subTitle、tbBox2、tbYellow/2、tbBlue、textBox2、button | 字體/尺寸/顏色/漸層；source inventory版本 | CMP-07；圖像與glyph缺失 |
| E-06 | CM/header.jsp:26–65、67–264、266–413 | tag情境、功能metadata/PD Y、body capture/window快捷鍵、copy獨立60s、session/時間/字體/浮水印；含berforeunload原拼字 | CMP-01/FLOW-01/06/07/BOUND/HANDOFF；底層實作/實際旗標未知 |
| E-07 | CM/msgDisplayer.jsp:1–59、61–100、103–171、174–185 | entry集/底欄優先序/rollback/0/99/exception、WIUtil+jQuery或alert、全頁button清底欄 | CMP-02/MSG-04/FLOW-01/08；host未知 |
| E-08 | CM/js/ajax/CSRUtil.js:15–29、154–337、371–700、702–745、2509–2594、2620–2638；onException:684–692 | ErrMsg.returnCode判斷、cover、系統/EP/native/jQuery分支、Responder註冊；onException 的原生 Error 診斷包含request URL、parameters、for-in例外屬性 | CMP-03/FLOW-04/09、MSG-07/TR-12/AC-15；actual host與browser未知；非目標錯誤schema |
| E-09 | CM/js/ajax/prototype.js:12、1935–1966、1994–1996、6475–6525、6681 | Version1.7.3；callback先complete/responder；成功／失敗callback catch→dispatchException→後續Complete，Complete catch另診斷；form重名key/CRLF | CMP-05/BR、TR-12/AC-15；不保證拋錯後所有剩餘responder完成，不是runtime觀察 |
| E-10 | CM/js/ajax/CSRUtil.js:1409–1696；1592–1604/1634–1673 | 空值灰占位、字串化/換行轉br後長度、去重/累積/寬度條件；焦點、確認不冒泡、單次keypress、拖黑框中間態 | CMP-04/FLOW-09/TR-10/11、AC-10/11/16；未實測browser尺寸 |
| E-11 | CM/js/RPTUtil.js:7–31、33–54、67–190、204–253、656–689 | 同步JSON下載helper/Safari延後；成功加密資訊→隱藏POST表單，false不開新target；既有form IE分支另開/關窗 | CMP-06/FLOW-05/BOUND-02；FileDownload未提供；不能當binary支持 |
| E-12 | inputs/backend/docs/OPENAPI.md:1–112、500–567、741–751 | 基準性質/共通ReturnMsg/HTTP200錯誤/operationId/所有AFY10400wire/下载binary/stub header/缺口 | API-01/02；不能证明部署/正式headers |
| E-13 | inputs/backend/docs/specs/AFY1_0400/AFY1_0400_doExport.md：doExport §1–6、logSecurity、createExcel | legacy逐列結果原文、CRLF、多保單查詢/稽核/檔案生成與异常；輸出Excel語意 | INT-01/MSG-03/HANDOFF-03；不是選定wire權威；內部SQL不轉前端規格 |
| E-14 | inputs/backend/docs/specs/AFY1_0400/AFY1_0400_doDownload.md：§1–6 | transaction目录+fileName→加密下载資訊、例外文字 | HANDOFF-04；不是target binary schema |
| E-15 | inputs/backend/docs/specs/AFY1_0400/AFY1_0400_doPrompt.md：§1–6 | 今日ROC日期與三flag初始化 | 本根未消費；不能由名字追加新UI |
| E-16 | CM/js/HotKey.js:58–107；root直接呼叫檢索；PageUI/Validator/calendar符號、date.js原始bytes ASCII tokens | HotKeys空actions，document keydown註冊；root沒有快捷鍵綁定/日期/validator直接呼叫 | date.js完整解碼未知，未從破損註解推導行為；排除未呼叫功能不作全系統不適用宣告 |

## 來源到契約覆蓋

| 來源事實 | E | 契約去向／原型 | AC／處理 |
|---|---|---|---|
| 初始化、hidden/nonvisible counter、include | 01/06/07 | FLOW-01、DATA-03/08/09、ST-01；SCR-01空列 | AC-01/07；未知tag/host TODO-01/02/04 |
| 新增ID/欄位/結果空、刪除、配色 | 02 | FLOW-02/03、UI-06–09、TR-02/03；动态列 | AC-02；已映射 |
| 多行保單/select/說明 | 04/09 | UI-03/04/05/08、DATA-01/02/05、INT-01 | AC-01/05，CRLF TODO-05 |
| 匯出空字串／後方duplicate順序／零列 | 03 | BR-01/02、MSG-01/02、TR-04/05/06；exportRequest | AC-03/04/13，未知服務結果未假成功 |
| 真正serialize，不發送临时param | 03/09 | DATA→API-01映射，CMP-05 | AC-05/13，target0列及換行TODO-05 |
| success回填→下载；failure回填不下載 | 03/11 | FLOW-04/05、TR-07/08、API-01/02、UI-09；合成receive | AC-05/06/12，TODO-03 |
| body/context/ctrl/print、copy與60秒交錯 | 06 | FLOW-06/07、BR-04、CMP-01、HANDOFF-01/02；全頁监听，審閱摘要 | AC-08/09，TODO-01/06 |
| policy信任來源/浮水印/font/load/unload/utility | 06 | DATA-09/BOUND-04、CMP-01；只揭露缺區 | AC-08，TODO-01/04，无推测画像 |
| 入口訊息/rollback/0/99/WIUtil/native | 07 | FLOW-01、MSG-04、CMP-02；入口情境替身 | AC-07，WIUtil未知停交接TODO-02 |
| 任何button清底欄；MsgWin confirm不冒泡 | 07/10 | FLOW-08、CMP-02/04；document click/closeModal | AC-07/10，底欄只審閱替身 |
| response缺JSON/ErrMsg/空文字、EP/custom/native、特殊id前綴 | 08/09 | FLOW-09、TR-09、CMP-03；review message-mode/receive | AC-14，與處理例外分列；jQuery/所有訊息分支未實測TODO-06 |
| callback／Complete拋錯、註冊診斷與後續生命週期 | 03/08/09 | FLOW-04/09、TR-12、MSG-07、CMP-03；合成成功／失敗映射損壞 | AC-15，已執行prototype mock，瀏覽器阻斷／Complete自身拋錯仍未觀察TODO-06 |
| MsgWin空值/灰字、正規化/去重/累積尺寸、單次keypress、拖曳中間態 | 10 | FLOW-09、TR-10/11、ST-06/07、CMP-04；review輸入型別/keypress/dragbox | AC-10/11/16，靜態與mock已核，真尺寸未實際視覺測試 |
| button基礎及後置root cascade；確定inline覆寫 | 05/10 | UI-06/07/10、CMP-07/04；CSS左右10px、確定15px | V-09靜態宣告核對；未宣稱rendering等價 |
| RPT helper同步JSON→加密資訊→隱藏表單、Safari/IE | 11/14 | CMP-06、FLOW-05、HANDOFF-04 | AC-12，未模擬實際瀏覽器download，TODO-03/06 |
| 交換wire/結果/envelope/下载headers | 12 | API-01/02、BOUND-01/02、HANDOFF-03/04 | AC-05/06/12，文檔核對，無live |
| 後端業務查詢/格式/檔案/稽核 | 13/14 | INT/MSG語意及HANDOFF，不搬入prototype | E只證明文件语意，runtime未取 |
| prompt全部4欄、compat promp | 12/15 | API未消費能力索引；沒有UI mapping | 排除追加日期/查詢/編輯；根未引用 |
| 沒有快捷鍵綁定/日期欄位/validator调用 | 01/16 | 專用快捷鍵與日曆不適用本頁，HotKey空map | 不建立無證據產品功能 |
| 圖像、實際host、浮水印工具缺失 | 01/06 | UI-01/02、CMP-01/02/03/07位置TODO | TODO-01/02/04；未知列保留於分母 |

### 混合責任 LOGIC

| LOGIC | 原順序／來源 | 責任與去向 | 承接／缺口 |
|---|---|---|---|
| LOGIC-01 | header 26–65，基底与config/utility→load時間/情境交付 | 可信情境与外部instrumentation，前端只消费；FLOW-01/BOUND-04 | HANDOFF-01/TODO-01 |
| LOGIC-02 | header 70–98，识别→getFuncInfo首筆→flag | 功能metadata与policy決策後端責任，前端仅依flag | HANDOFF-01/TODO-01；不由prompt補 |
| LOGIC-03 | header 101–254，按flag注册policy→copy/timer→稽核 | 呈現/事件与資料副作用拆開；FLOW-06/07 | HANDOFF-02/TODO-01，無網路實作 |
| LOGIC-04 | header266–413，session identity/time/font→watermark/load/before事件 | 可信取得後端；條件呈現/工具前端；原拼錯保留 | HANDOFF-01/TODO-01/04 |
| LOGIC-05 | copy選取/比較/timer與請求資料 | 前端事件生命週期，後端持久稽核 | BOUND-03/HANDOFF-02 |
| LOGIC-06 | msgDisplayer1–59→137–171，再document click | 服务response集取得後呈現转換/外部host调用；FLOW-01/08 | DATA-08/CMP-02；目標msg schema不足TODO-02/03 |
| LOGIC-07 | root67–97 UI值检核→serialize | UI guard呈現前端；不能替代业务validity | FLOW-04/BR-01/02，API-01合法UI來源 |
| LOGIC-08 | root98–113 resp map→row result→fileName | 結果呈現前端、查詢/生成file服務；failure map仍需要 | API-01成功已定義；HANDOFF-03/TODO-03 |
| LOGIC-09 | root106→RPT同步→加密資訊→FileDownload | 前端交接；檔案/加密下載服務 | API-02但不相容原helper；HANDOFF-04/TODO-03 |

### API／HANDOFF 追蹤

API-01成功可定位E-12，錯誤data=null差距未解；API-02成功binary可定位但JSON helper不相容。HANDOFF-01/02基準內未取得承接，HANDOFF-03/04仍未確認相容變更。prompt能力未誤新增UI；正確rtype與相容promp保持。沒有外部backend修改。

## TODO 與後續

### TODO-01

開啟／缺依賴与未承接。DEP-08、E-06：實際功能policy/水印旗標、登入/時間/環境信任與copy記錄接收/落地未知。影响FLOW-01/06/07、DATA-09、BOUND-03/04、HANDOFF-01/02、AC-08/09。DEC-01明确延後；[TASK-06](plan.md#後續任務)：取得tag/功能metadata/utility、trusted身份与稽核契約→對照HANDOFF→補合法映射→重驗AC-08/09及旧計時交錯；有可定位承接/情境與必要實測才關閉。尚未解決。

### TODO-02

開啟／不可取得。DEP-09、E-07/08：底欄host/rollback来源、WIUtil内部、实际系统location与外部forced jQuery未知。影响CMP-02/03、FLOW-01/08/09、UI-10、AC-07/14。来源已证实条件反应仍保留，不因actual branch未知省略。DEC-01延後；[TASK-07](plan.md#後續任務)：取得底欄与host/script版本→先轉必要共用→更新位置契约与prototype→重验入口/異步各不同文案/清除/rollback/焦点。缺host不可以永久底欄替代。尚未解決。

### TODO-03

開啟／跨權威差距。E-03/08/11/13/14對E-12：ErrMsg.returnCode与ReturnMsg.code，rtnMap顶层与data包裝，错误data=null与原failure map，原markup结果與target文字、JSON加密資訊下载與binary。影响FLOW-04/05/09、UI-09、API-01/02、HANDOFF-03/04、AC-05/06/12/14。DEC-01延後未知承接；[TASK-08](plan.md#後續任務)：取得相容承接或明确變更證據→更新映射/MSG/TR→檢查全部成功/拒絕/部分输出与顺序。不能自己新增字段或抹掉原失败回填。尚未解決。

### TODO-04

開啟／呈現依賴不可取得。DEP-09、E-01/05/06：border_01/02/03、ecblank、icon_dot11、bt_bg、cover/loading images、難字字體、水印工具缺。影响UI-01/02、CMP-01/07、FLOW-01/09。DEC-01延後；[TASK-07](plan.md#後續任務)：取得資源與版本→只替換有證據資產→核對字体/浮水印/装饰与实际flag；必要來源支持后才能宣告视觉覆盖。原型不臆造品牌icon/水印。尚未解決。

### TODO-05

開啟／API未明定。E-12 §10：正式url/gateway/认证、完整enum、長度、null/空白/array一致性/零列规则与targetJSON CRLF接受条件；下载正式headers/保留/部分输出保证未知。影响BOUND-01/02、API-01/02、AC-05/12/13。DEC-01延後；[TASK-08](plan.md#後續任務)：取得发布契约/environment与正式adapter→保留wire精确字段对照→再實測; 不由stub/文档存在推断部署或授权。尚未解決。

### TODO-06

開啟／部分已驗證。没有legacy执行画面（任务禁止legacy执行）；舊交付未作browser觀察，本輪已取得主代理Chromium原型報告，具體18/19結果及修補後待重驗見V-11/12。影响SCR-01、动态窗尺寸/drag/keyboard、policy print、copy60秒实际时序、RPT浏览器分支、real integration。依据静态来源+prototype模拟不得宣告像素/行为等价。[TASK-09](plan.md#後續任務)：在获准环境开原型→实际操作AC-01–14并截图/console/network检查→来源素材可用时比對，补结果；动态測試無法执行的分支保持未执行。尚未解決。

## 原有差異與未確認改良

| 來源 | 已知差異 | 改良狀態 |
|---|---|---|
| header E-06 | berforeunload拼字与modern/fallback handler差异 | 未改；如何修正未確認，不混入原型 |
| CSR E-10 | 第一keypress无条件解除，先字母后Esc不關 | 按源保留，不改成持续Esc |
| E-03 | 0列无guard，空白不trim，短ID无exact10前端限制，原innerHTML支持markup | 仅记录，不私自「改善」验证；target差距TODO-03/05 |
| E-13 | sb每列清空，后置長度檢查通常不触发 | 後端方法語意记录；原型未重製算法 |

## 驗證執行與交付判定

结果记录后续增补本节，脚本与实际输出只在artifacts。未经浏览器打开不写视觉通过，未呼叫service不写介接通过。

## 增量紀錄

CHANGE-01／2026-10-12：首次快照；先plan后deps，support-v1再root v1。所有E新建，TODO-01–06开啟。內部來源核對時以實際RPT getForm（不設定新target）及Prototype1.7.3修正先前草稿，沒有將猜測保留為契約。

## 實際驗證紀錄（2026-10-12）

| V | 依據／環境與操作 | 實際結果與證據 | 判定／限制 |
|---|---|---|---|
| V-01 | 舊交付僅支持16來源hash版本鎖定；完整解碼／行號宣告被AF-SR-01否定 | date.js原編碼／1,430行無效；CHANGE-02/V-08由原bytes重核；舊inventory保留immutable prior-artifacts | 僅hash有效，不能支持舊date編碼／行數 |
| V-02 | 執行 [static_check.py](checks/static_check.py)，解析Markdown連結／anchor、HTML id、產品root及外部請求模式 | [static-result.json](../../../inputs/prior-artifacts/renovation/AF-AFY10400/checks/static-result.json)：94 links/anchors（含驗證紀錄新增連結後重跑）、26 HTML ids、16 hashes，0 failures，0 external refs；无未替換占位符 | 通過；動態UI IDs由腳本來源另核對，靜態沒有意外外部src/href，不等同network面板觀察 |
| V-03 | Node v22.18.0 `node --check checks/prototype-script.js`；提取的是prototype腳本，不是legacy | 腳本語法檢查 exit0 | 通過；未載入瀏覽器 |
| V-04 | [prototype_mock_check.cjs](checks/prototype_mock_check.cjs)在Node VM最小DOM替身執行prototype，不执行legacy；合成例值、fake time | [mock-result.json](../../../inputs/prior-artifacts/renovation/AF-AFY10400/checks/mock-result.json)：9組behavior assertions通過；AC-01/02/03/04/05/06/08/09/10/11/13的可展示部分；檢查回填→下載摘要→complete順序、一次keypress、拖黑框與真窗隱藏／恢復、獨立60s舊到期 | 通過本機mock範圍；事件bubbling、尺寸、瀏覽器預設与真60秒未實測，不能宣告AC整體通過 |
| V-05 | 文件人工核對E-12 §1–3/6/10和本投影，E-03/08/11与source支持 | API-01/02精確wire大小寫、array、ReturnMsg、200/code500/data null、binary、stub-only disposition；prompt rtype与compat promp全部記錄为未消費 | 通過文件投影核對；TODO-03/05相容與正式環境未解，無backend呼叫 |
| V-06 | 查本機終端可用命令`node chromium chromium-browser google-chrome playwright python3` | 找到node与python3；無列表內browser/playwright命令。未嘗試下載browser、未call網路。沒有本輪browser截圖/console/network實際觀察 | 瀏覽器檢查未執行；TODO-06開啟。只說終端可用性，不能推斷其他宿主browser不可用 |
| V-07 | AC-07/12/14需真实底欄／WIUtil／download与response不同branch，legacy比對禁止 | 已有案例與條件式文字契約；目前未執行host、jQuery/EP/所有例外、download Safari/IE或正式API | 未執行；TODO-02/03/05/06 |

本輪結論：已完成单根來源盤點、必要共用片段契約、入口中立規格、離線原型、API消費投影、后端移交与分離追蹤；靜態与mock檢查有實際紀錄。所有已辨识來源列已映射／具體TODO／有依據排除，未知依赖內部仍未盘点，未报告虚假100%覆盖。TASK-01–04在可取得範圍完成，TASK-05已執行可行檢查，TASK-06–09延後。交付判定仍為**部分**，TODO-01–06未解；缺依赖、相容差距、browser与正式介接不能由文件產生或mock通過代替。

## Review 續作紀錄（CHANGE-02／2026-10-12）

根入口及後端snapshot版本未變；先增補TASK-10/11，再核對原始bytes／分支與immutable prior delivery。六項AF-SR皆確認，無無證據的異議。主規格v1.1、共用support-v1.1供本輪引用，既有ID與E保留；[prior support-v1](../../../inputs/prior-artifacts/design/AF-AFY10400-support/contract.md)供歷史核對。新增MSG-07/TR-12/AC-15/16，未新增root或API。V-02/04/06是舊交付的parser／mock／工具可用性紀錄，不是本輪重新觀察；其原輸出保留於inputs/prior-artifacts，checks最新輸出以V-08–10為準。

| Review | 原始來源核對 | 修補／去向 | 驗證與限制 |
|---|---|---|---|
| AF-SR-01 | date.js hash匹配；1,089 byte-lines；strict utf8 offset8、cp950/big5/big5hkscs offset40 | inventory逐檔byte/codec證據；tracking來源及V-01改正；date文字意圖不猜 | V-08/09；不可讀註解仍是input限制 |
| AF-SR-02 | CSRUtil:684–692/2620–2637；Prototype:1942–1964/1994–1996；root:99–111 | CMP-03、MSG-07/TR-12、FLOW-04/09、AC-15；合成成功／失敗映射損壞 | V-10；診斷動態值及後續生命週期；非新安全回退／target錯誤能力 |
| AF-SR-03 | CSRUtil:1592–1604/1634–1673 | CMP-04/FLOW-09/AC-16；空值gray span、正規化長度、累積去重／條件增寬；審閱型別 | V-10；實測寬及灰字rendering仍TODO-06 |
| AF-SR-04 | cm.css:108–124/162–164；CSRUtil:1449–1451 | CMP-07，後置root selector左右10px，確定inline15px保留 | V-09宣告核對；未宣稱computed style/像素等價 |
| AF-SR-05 | dependencies每個受影響位置連tracking與TASK/DEC | design/integration所有bare TODO連結；API array/enum/CRLF/data補local link | V-09；TODO-01–06仍開啟 |
| AF-SR-06 | evidence中立規則；來源角色／順序有效 | FLOW-04/05/08/09改可讀回應、頁面結果處理、交換結束、親頁訊息區與外部呈現者；精確技術留CMP/API/E | V-09 FLOW檢索；診斷可見原文保留 |
| 本輪補核：審閱回應注入順序 | msgDisplayer:174–185全頁button清底欄；CSRUtil:480–499非同步回應→完成 | respond的合成回應排於click傳播之後，仍保留所有button清舊底欄及確定不傳播 | V-10原microtask模型已被實際Chromium否定；CHANGE-03改下一個事件任務交付，V-12重驗，不擴產品功能 |

### 受影響缺口位置核對

回讀實際design/integration文件；逐行位置及錨點列於 [gap-location-result.json](checks/gap-location-result.json)，包含資料／狀態／轉移／API欄位與TODO→TASK／DEC-01。這是實際位置紀錄，不聲稱未知依賴內部已全部分析。

| 實際位置 | 本地錨點 | 後續／既有決策 |
|---|---|---|
| specification DATA-06、ST-05、TR-08、MSG-03、FLOW-04/05；API-01 code/data/rtnMap/錯誤 | [TODO-03](#todo-03) | TASK-08／DEC-01 |
| specification DATA-09、FLOW-01/06/07；support CMP-01；HANDOFF-01/02 | [TODO-01](#todo-01)、[TODO-04](#todo-04) | TASK-06/07／DEC-01 |
| MSG-04/05、FLOW-01/08/09；CMP-02/03；API msg | [TODO-02](#todo-02)、[TODO-03](#todo-03) | TASK-07/08／DEC-01 |
| API-01 insrType/prodType/I_ID/POLICY_NO、零列；API-02正式能力 | [TODO-05](#todo-05) | TASK-08／DEC-01 |
| MSG-07、FLOW-09、AC-15/16；CMP-03/04 | [TODO-06](#todo-06) | TASK-09；本輪static/mock |

### 本輪實際驗證

| V | 操作／依據 | 實際結果 | 限制 |
|---|---|---|---|
| V-08 | skill source_inventory.py逐份bytes，utf-8/cp950/big5/big5hkscs strict；static_check獨立重核 | [source-byte-result.json](checks/source-byte-result.json)與inventory：16來源hash/byte-lines/行尾/codec status一致；49 manifest hashes匹配；date strict失敗明列 | codec valid不證明唯一預期編碼；date註解仍未知；inputs/skill/manifest未改 |
| V-09 | Python3 [static_check.py](checks/static_check.py)；Node v22.18.0語法檢查prototype-script.js | [static-result.json](checks/static-result.json)：links/anchors、28 HTML IDs、16 byte-records、button cascade、root FLOW檢索通過，0 failures/外部refs；語法exit0；實際缺口位置輸出 | parser/CSS文字不是rendering/network panel；只Markdown wire投影；未執行legacy/backend |
| V-10 | Node VM最小DOM/fake time執行 [prototype_mock_check.cjs](checks/prototype_mock_check.cjs)，只執行prototype | [mock-result.json](checks/mock-result.json)：15組assertion；保留9組舊scope，加空/null/undefined灰字/累積，450保持/600上限/確認後180，換行去重/240px，成功及失敗診斷先於完成、不回填下載，button清舊訊息後注入新訊息留存 | controlled DOM width，灰色span style assertion，alert同步mock；非實際modal阻斷、事件／rendering／服務等價；未稱AC整體通過 |

TASK-10修補完成；TASK-11完成可行static/mock。TASK-06–09及TODO-01–06仍開啟：受信任情境、host/圖像/字體/浮水印、失敗逐列結果、binary下載相容、正式API規則與真正宿主仍無新外部證據；後續原型Chromium觀察另見CHANGE-03。續作交付仍為**部分**，不把來源限制／產檔／mock當正式整合完成。

## Chromium 回饋與事件修補（CHANGE-03／2026-10-12）

[修補前實測報告](../../../reports/browser-before-event-fix.json)由主代理提供，Chromium 151.0.7922.34、1280×900、只執行生成原型：18/19情境PASS，bottom-receiver-after-callback FAIL，errors/networkAttempts空。該報告及修補前結構／原型證據保持不變。本代理只讀此實際回饋報告，未讀browser suite或評估腳本。實測證明先前V-10的minimal DOM把微任務排在document click後，不能代表原生使用者click的真實順序；舊「microtask足以保留底欄」主張失效。

原契約不變：msgDisplayer:174–185在按鈕click清親頁訊息區；CSRUtil:480–499/後續Complete在非同步服務回應後交付新訊息。審閱respond只是外部回應替身。以setTimeout(receive,0)將合成回應交付排於下一個事件任務，等待整個click完成；沒有豁免document按鈕規則，也沒有改CMP-04確定不傳播或新增服務能力。只是原型審閱工具排程修補，不把0ms變成產品或API逾時需求。

| V | 操作／證據 | 結果 | 限制 |
|---|---|---|---|
| V-11 | 主代理提供[修補前Chromium報告](../../../reports/browser-before-event-fix.json) | 18PASS/1FAIL；底欄回應在原生click後為空；無console errors/外部network attempts | 是實際生成原型觀察，非legacy／backend等價；尚無修補後browser結果 |
| V-12 | harness在target handler後、document傳播前執行微任務；下一個timer任務由tick(0)另行交付；重跑static/Node語法/15組mock | [mock-result.json](checks/mock-result.json)與[static-result.json](checks/static-result.json)通過；[event-timing-result.json](checks/event-timing-result.json)記錄in-memory換回旧queueMicrotask被同一情境拒絕（空字串與預期新訊息不符），未寫回舊source；新任務邊界保留回應訊息 | 回歸仍是controlled DOM/task模型；修補後真實Chromium由主代理另跑，不先宣告PASS |

TASK-12完成修補與可行本機檢查，等待主代理實際browser重驗。TODO-06的「原型從未實測」已被本報告取代；必要未測browser分支、legacy圖像比較與真正宿主仍未知，故TODO-06保持開啟；TODO-01–05及部分交付判定不變。

## 訊息窗重新開啟按鍵修補（CHANGE-04／2026-10-12）

主代理獨立來源核對指出outer mutable keyHandler閉包缺陷。本代理以原bytes strict CP950重核CSRUtil:1609–1632：每次show建立local keyPressHandler，第一次keypress移除的是自身。原型舊handler則讀取外層被下一次show覆寫的值；滑鼠確認未觸發keypress而重開後，舊handler誤移除新handler並殘留，後續Esc會關窗。此為已確認生成缺陷，不是來源缺口。

改為每次fresh show的const firstKeyHandler，保留滑鼠確認不主動清listener的來源生命周期；首字母讓未耗用的舊／新handler各自移除，後續Esc不關窗，再開新窗首Esc仍關閉。CMP-04、AC-10與harness同步補「顯示→滑鼠確認→重開→字母→Esc→再開→首Esc」；next-task回應注入不變。

| V | 操作 | 結果 | 限制 |
|---|---|---|---|
| V-13 | static/Node語法與16組prototype-only mock；in-memory換回舊mutable closure、抑制輸出寫入 | [mock-result.json](checks/mock-result.json)通過；[key-handler-result.json](checks/key-handler-result.json)：舊closure於首字母後仍殘留1個listener（預期0）被同一回歸拒絕；修補後窗口保持且再次首Esc可關 | 最小DOM事件fixture，不作瀏覽器等價；主代理另驗原生事件；無legacy/backend/network |

TASK-13本機修補及檢查完成，實際Chromium重開情境待主代理確認。部分交付與全部input／外部相容缺口仍開啟；既有ID與來源snapshot未改。

## 審閱層遮擋修補（CHANGE-05／2026-10-12）

主代理[修補前原生Chromium報告](../../../reports/browser-before-review-layer-fix.json)：19/20情境PASS（包括已等待非同步完成的底欄回應），reopened-message-single-keypress-listeners因review-content攔截message-ok滑鼠點按而FAIL；errors/networkAttempts空。報告保留不動。這是人工審閱層遮擋產品訊息窗，該失敗並未驗證或否定key-handler回歸結果。

原bytes strict CP950來源核對：CSRUtil:210/221定義cover預設zIndex150，1441定義MsgWin999。產品來源層級保持；只改人工review的1500→151，讓cover150 < review151 < msg-window999 < dragbox1000。合成回應控制仍在pending遮罩之上，訊息窗／確定在人工審閱區之上。沒有force-click、程式呼叫close取代原生測試，沒有改全頁button清底欄、訊息窗callback或產品層級；151是人工審閱載體設定，不是產品需求。

| V | 操作／證據 | 結果 | 限制 |
|---|---|---|---|
| V-14 | 主代理[修補前報告](../../../reports/browser-before-review-layer-fix.json)及原來源layers | 19PASS/1 pointer-interception FAIL；底欄回應PASS；重開keypress情境因實際滑鼠無法確認而未完成 | 只generated prototype；修補後原生點按仍待主代理重跑 |
| V-15 | static_check新增CSS層級關係檢查；Node語法及16組mock重跑 | [static-result.json](checks/static-result.json)：產品cover150/msg-window999保留，review151介於其間，dragbox1000；0 failures；[mock-result.json](checks/mock-result.json)16組PASS；語法exit0 | CSS宣告及minimal DOM不證明hit testing；原生點按由主代理檢查，未force-click |

TASK-14局部修補／本機檢查完成，實際browser重驗待主代理。所有來源input及外部依賴缺口仍開啟；沒有把19/20或局部靜態／mock當legacy或正式整合完成。

## 主代理瀏覽器確認（CHANGE-06／2026-10-12）

| V | 實際操作與環境 | 結果與證據 | 限制 |
|---|---|---|---|
| V-16 | 原生 Chromium 151.0.7922.34、1280×900，新 context、合成資料、HTTP 全阻擋；重跑既有流程與已知邊界、CSS cascade、底欄非同步回應、原生滑鼠確認後重開 | [browser.json](../../../reports/browser.json) 20/20 PASS，0 console/page errors、0 HTTP attempts。原型 SHA-256 `733761aff333f051ecaec8ff0211f4d6964708346a3d4ca7982baba157005ebe`；callback 經條件等待後核對，訊息窗不受人工層遮擋 | 鍵盤回歸中的 Escape 使用合成 keypress，證明來源條件與 listener 身分，不證明原生 Escape 相容性。未執行 JSP／後端／宿主，沒有來源畫面像素等價證據 |

TASK-12–14 的生成原型修補已取得上述瀏覽器證據；先前「待主代理重驗」是各階段歷史狀態。TODO-06 中本輪已列出的 prototype 情境已實测，legacy 畫面、真正宿主及其他必要外部驗證仍未取得，故保持開啟。TODO-01–05 及部分交付判定不變。
