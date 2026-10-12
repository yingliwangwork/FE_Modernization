# eBAF 後端工具的設計參考與產物探索

## 本次參考位置

使用者提供的工具位於 `/Users/cfh00911058/Desktop/AI in IT/Workspace/AF_DEMO/AF_SRC/.github`。它提供分析、領域轉譯、功能整合、後端設計、驗證及規格同步方法。本 skill 參考其中的設計理由，不執行或複製其後端開發流程。

以下路徑皆相對於該 `.github` 目錄：

| 已參考文件／章節 | 採用的設計理由 | 在前端的調整 |
| --- | --- | --- |
| `workflow-reference.md`：階段一、三、五、增量更新 | 分離來源分析、契約設計、同步與增量工作 | 分離前端規格、介接投影和翻新追蹤，不引入後端實作層級 |
| `skills/ebaf2spec-trx-analyze/SKILL.md`：Scope、R1、R3、R4 | 精確分析單位，具體條件，資料取得與組裝，工具契約查閱 | 單位改為一個 JSP；前端初始化與載入仍需分析，不沿用排除 start/initApp 的限制 |
| `skills/ebaf2spec-biz-validate/SKILL.md`：R2 | 先建來源步驟盤點，再比對所有呼叫、條件及結果 | 建 JSP 事件／分支／耦合責任覆蓋表，不能只核對元素名稱 |
| `skills/spec2domain-method-rewrite/references/translate_rule.md`：R-A1、R-A3、R-A5 | 權威 mapping，保留代碼／訊息，禁止望文生義 | 中立語意可轉譯，API wire 名稱、結果碼及後端原文保持不變 |
| `skills/springboot-controller-design/SKILL.md`：R2、R3 | 範本不是業務來源，不編造缺少的契約，區分邊界與業務責任 | API spec 只轉寫已選定後端產物；不能從範本推導 method、path 或 DTO |
| `skills/design2code-spec-resync/SKILL.md`：R1、R2、R3 | 契約保留當前行為，疑問不自行改動，排除實作細節 | API 投影鎖定版本並揭露漂移；變更歷史留在 tracking，不自行同步或覆寫後端 |
| `copilot-instructions.md`：框架工具、SQL／資料來源 | 自訂工具語意與資料型別需有依據 | JSP 用到工具時按需讀 `ebaf/*_copilot.md`；缺契約列 TODO，不採納「合理描述」為確認事實 |

工具內的技術棧、路徑命名慣例、固定 method、agent 調度、編輯方式及特定業務例子不作為本前端 skill 的全域要求。

## 後端產物在哪裡

本輪實際翻新時以 `backend_root` 作為後端專案根，不硬編碼上述個人路徑。產物清單由實際檔案和後端交付紀錄確認：

| 可能的產物 | 可支撐的範圍 | 不能單獨支撐的內容 |
| --- | --- | --- |
| `docs/OPENAPI.md`，或後端交付的 OpenAPI 檔案 | 指定版本的對外介面、序列化、共通回應與例外 | 缺列的動態欄位、部署身分機制、所有正式環境結果 |
| `docs/design/*Controller_design.md` 及相關設計 | 已確認設計中的入口、輸入輸出與校驗 | 設計是否已落實、未寫明的全域序列化／例外 |
| `docs/design/*Service_design.md`、`docs/specs/**/*.md`、`docs/sa_spec/*.md` | 業務條件、處理順序、資料及副作用 | 未明定的 HTTP 暴露方式 |
| 後端交付的契約測試、驗證紀錄與適用實作 | 特定版本／環境的驗證與差異證據 | 不能自動取代已指定權威；有矛盾需揭露 |
| Mock／stub 指引與回應 | 替身環境的可演示能力 | 正式交易、權限、真實資料及不存在於正式契約的欄位 |

本次在該工具的專案根確認存在 `docs/OPENAPI.md`，其文件宣告為依現行 Controller、DTO 和共通例外盤點的契約；亦存在 `docs/AF_AT_API_MOCK_GUIDE.md`。這證明有介接材料可引用，不代表已核准它們為所有後續 scope 的基準，也不代表已驗證全部端點。

`docs/OPENAPI.md` 是 Markdown 描述，不因名稱就視為可由 OpenAPI parser 驗證的 YAML／JSON。不同產物可能有欄位、相容路徑或 stub 描述差異；每輪仍需依 [權威分工](authority.md) 鎖定基準。前端翻新不啟動後端、生成後端程式或修改其文件。
