---
name: jsp-to-spec
description: 將指定工作區內的單一 JSP 逆向轉換為技術中立的前端系統設計規格及逐狀態硬編碼 HTML 視覺規格。先盤點依賴，以介面契約與 suspending points 隔離缺件及非 JSP SOT；不執行整站翻新、後端轉換或任務規劃文件產製。
argument-hint: jsp=<單一JSP路徑>
user-invocable: true
disable-model-invocation: true
---

# LLM-Optimized Instructional IR: JSP to Frontend Specification

## Goals

### Primary
以使用者指定的**單一 JSP 為轉換起點**，讀取專案設定範圍內的相關文件，以 bottom-up 方式產出明確、技術中立的前端系統設計規格，以及每個畫面狀態各自硬編碼的 HTML 視覺規格。

### Secondary
1. 完整描述「使用者介面 ↔ 頁面協調／規則 ↔ 外部能力」的互動與資料流，保留原始邏輯而非逐字轉譯技術語法。
2. 先盤點依賴，再在已指定範圍內讀取所需證據；對非目標 JSP 的 SOT 與缺件，以消費端介面契約及 suspending points 處理依賴反轉。
3. 每個規則、流程及畫面皆可追溯來源；不以假設冒充後端現況或宣稱未經驗證的等價。

## Constraints

### Scope Determination
- 唯一呼叫參數：`jsp=<單一 .jsp 路徑>`，亦接受直接提供該路徑；含空白時加引號。不要求每次再提供 workspace、output 或 sot。
- 來源、SOT 與產物位置由本平台的 [../../jsp-to-spec.yaml](../../jsp-to-spec.yaml) 固定設定；選擇及路徑解析依 [references/project-settings.md](references/project-settings.md)。jsp 缺少、定位有歧義或目標不可讀時才詢問必要資訊。
- **單一 JSP 限制的是轉換及交付目標，不是 AI 能讀的文件數量。** 應主動讀取設定範圍內與此頁相關的 include、其他 JSP、JS、CSS、tag、Controller、DTO、API／資料契約與設定文件；必要時循引用追查供應資料或事件處理，直到能說明此頁介面與行為。
- 不將讀取相關文件擴張成其他文件的獨立轉換或整站翻新；不無差別讀完整專案。非目標 SOT 的供應端細節仍以依賴反轉契約隔離。
- 完整分析目標 JSP 的內嵌腳本及 scriptlet。不得執行來源程式、呼叫 API 或自行擴大到未設定的來源專案。

### Language and Format
- 預設繁體中文，保留原始欄位、端點、scope、文案及證據識別字。
- 規格以自然語言、決策表及資料流表表達；不得要求特定前端框架、套件或元件 API。
- 依 [templates/frontend-spec.md](templates/frontend-spec.md) 產出一份系統設計規格。八個頂層章節保持順序；章節內可依複雜度細分，無適用內容須說明依據，不能空白略過。
- 各章寫法參照 [references/spec-writing.md](references/spec-writing.md)，不要把模板提示文字或佔位符原樣交付。

### File Location and Roles
- 所有**轉換產物與該次整理的參照產物**放在設定檔 `output_root/<頁面名稱>/`；目前預設 `.agents/docs/<頁面名稱>/`。位置在 `.github/` 或 `.agents/` 下的設定檔一次指定，不作呼叫參數。
- 本次執行專案取 session 的工作目錄；來源目錄與 SOT 目錄分別讀取 `source_roots`、`sot_roots`。隔離驗證使用暫存專案自己的設定，不修改正式設定。
- 盤點、SOT 摘錄、原始資料／介面、追溯與未決事項整合進最終 spec.md，不另散落為報告。禁止把該次參照產物寫入 skill 的 references／examples。
- skill 的 `references/` **只存通用規範**：JSP 語意、抽象轉換規則、依賴反轉原則及最終規格各章寫法；`templates/` 與 `examples/` 分別是可重用模板及明示的教學範例。
- **維護工具的 main agent**只修改 skill 相關文件（含平台根目錄的 jsp-to-spec.yaml），不在專案寫轉換交付物或設計歷程；轉換／行為驗證交給獨立 subagent／session。驗證產物放在暫存專案設定的 output_root 下。
- **執行轉換的 agent／session**只寫指定 output，來源與 skill 唯讀；不自行擴展為整站／batch 流程。無 subagent 能力時，維護工具的 main agent 提供新 session 呼叫方式，不自行突破角色邊界。
- 本專案以 `.agents/skills/jsp-to-spec/` 為維護主本，`.github/skills/jsp-to-spec/` 為 Copilot 分發副本；正文與資源同步，僅平台 metadata 可不同。保留原有明確呼叫政策。

### Final Artifact Boundary
- 最終交付僅一份 `<頁面名稱>.spec.md` 及各狀態的 `<頁面名稱>.<狀態ID>.html`。
- 禁止落盤或交付 task、plan、待辦清單、分析歷程及實作應用程式；設計過程只留在 session。
- 缺少依賴不能以計畫或缺件通知替代已有證據可完成的規格與 HTML。

## Rules

### R1: Inventory Before Dependency Reading
先讀固定設定、盤點 source_roots／sot_roots 的檔名，再完整讀目標 JSP、建立依賴表；依引用或具體資料／事件需求定位並讀取相關文件。SOT 可由設定位置及引用自行發現，不要求使用者逐份指定。新發現依賴先補盤點再讀；禁止先全文探索專案。路徑、定位與缺件判定依 [references/dependency-boundary.md](references/dependency-boundary.md)。

### R2: Business Logic, Not Syntax Translation
精確還原條件優先順序、獨立分支的組合、空值語意、集合順序、驗證順序、資料映射、格式化、事件與錯誤結果。來源語法只作證據定位，不作新技術實現要求。抽取規則見 [references/semantic-extraction.md](references/semantic-extraction.md)。

### R3: Interaction and Data Flow
每個流程需有觸發者、前置條件、輸入來源、判斷順序、資料傳遞、回應分支、畫面／焦點／導航結果。每個「UI → 頁面規則 → 外部能力 → UI 結果」的箭頭，都需明確資料、契約或 suspending point；「呼叫後端後更新畫面」不算規格。

### R4: Dependency Inversion and Suspending Points
先列**供應端原始資料與既有介面證據**，再列**此頁所需能力**（`C-*`）及映射。區分 `已觀察／SOT證實／消費端需求／未決`，不得捏造端點、型別、回應格式或把 render model 改稱 JSON API。非目標 SOT、缺件及衝突依 [references/contracts-and-suspension.md](references/contracts-and-suspension.md) 處理，每個 SP-* 寫明影響、暫時呈現、解除證據與驗證方式。

### R5: One Static HTML Per Visible State
各個可達且可見內容／結構／可用操作不同的狀態各一份完整 HTML；不能任意限縮數量。內容與示例資料寫死，不用程式生成、載入或切換狀態；同一 HTML 不承載多個條件狀態。等價分類需有理由，未知分支不可假造。依 [references/static-visuals.md](references/static-visuals.md) 及 [templates/state.html](templates/state.html) 製作。

### R6: Evidence and Completion Claims
建立「來源行號 → 規則 R-* → 流程 F-*／契約 C-* → 狀態 S-*／HTML」追溯。零未決且目標 JSP 行為均有證據才可標「單頁範圍完整」；仍有 SP 時標「邊界已規格化，依賴待確認」。不得宣稱原系統完整等價。

## Workflow

1. **Read Settings, Template and Writing Rules**：讀取平台固定設定、規格模板及 spec-writing，解析 jsp、來源／SOT 根目錄與 output_root；不能透過符號連結越界或覆寫來源。
2. **Inventory and Read Related Files**：依 R1 先列檔及引用、記錄存在狀態，再讀取相關依賴；必要時循引用追到資料／行為契約可確認為止，不因來源不是目標 JSP 而停止。每次擴展先補盤點，不進行無關專案分析。
3. **Analyze Target JSP**：依 R2、R3 逐段還原目標 JSP，將行號、資料、條件、事件、規則與流程保留於 session。
4. **Define Boundary Contracts**：依 R4 先整理原始介面證據，再寫消費端需求及 SP；未知處只懸置受影響斷言，不停掉其餘交付。
5. **Generate Specification and Visuals**：依模板寫規格，再依 R5 將所有畫面狀態展開為固定 HTML；狀態表連結每個檔案，未知區塊明示 SP。
6. **Verify Compliance**：閱讀 [references/acceptance.md](references/acceptance.md)，比對語意、追溯與狀態覆蓋，並執行下列結構檢查：
   ```sh
   python3 <skill目錄>/scripts/validate_artifacts.py <output目錄> --spec <頁面名稱>.spec.md
   ```
   腳本不證明語意等價。無 Python 時手動檢查相同條件並記錄未執行腳本。有瀏覽器能力時逐一開啟 HTML 驗證版面；否則明確記錄視覺未驗證。
7. **Deliver**：連結實際 spec.md 及所有 HTML，簡述實際驗證與未解除 SP；不能只回覆流程、計畫或任務摘要。

## Examples

### Example 1: Invocation
```text
使用 $jsp-to-spec，jsp="views/order.jsp"。
```

### Example 2: Conditional UI
**正確**：「可編輯旗標為真時顯示儲存操作，否則不顯示；點選後依序驗證輸入，再把原始值交給儲存能力 C-02。」
**錯誤**：「將 c:if 改為 v-if，並建立前端框架 state。」

### Example 3: Isolated Exercise
[examples/order.jsp](examples/order.jsp) 與 [examples/order-api.md](examples/order-api.md) 是可複製到暫存來源的教學夾具，不是本次轉換的參照產物。先在暫存專案設定來源／SOT／output_root，再讓獨立 agent 僅以 jsp 試跑；示例解讀見 [examples/semantic-mapping.md](examples/semantic-mapping.md)，不得將範例業務規則套用到其他 JSP。

## Output Format

```text
<設定檔 output_root>/<頁面名稱>/
    <頁面名稱>.spec.md
    <頁面名稱>.S-01.html
    <頁面名稱>.S-02.html
    ...每個不同畫面狀態一份
```

spec.md 八章依序為：範圍與證據、依賴盤點與邊界、原始資料與頁面需求契約、系統流程與互動、規則／資料／UI 結構、畫面狀態與靜態視覺規格、Suspending points、追溯與驗證結果。

## Evaluation Criteria

- 呼叫只需 jsp；其他位置由固定設定取得。已先盤點並讀取相關依賴，沒有把 AI 的讀取範圍誤限為單一 JSP，也沒有全文探索整個專案。
- 規格具備全部已知規則與雙向資料流，不依賴特定前端實現；各行為可追溯來源。
- 原始供應資料與消費端需求分開；非目標 SOT、缺件、衝突均有明確契約／SP。
- 所有不同可見狀態各有硬編碼 HTML，狀態、示例資料與文案符合來源；檔案可離線開啟。
- 所有轉換及參照產物都在設定的 output_root（預設 `.agents/docs/`），並整合為一份 spec.md 加各狀態 HTML；沒有 task／plan 交付物。
- 實際檢查結果及限制如實記錄，未以結構檢查宣稱完整語意等價。
