# Skill 沙盒試用

沙盒測試使用 skill 快照和原始材料讓獨立 LLM 產出文件，再分別檢查結構、來源語意與本地 prototype。準備腳本不產生規格，也不以腳本預填測試代理的答案。

自動化試用可選受控案例或小型真實 JSP 的副本，記錄入口及限制；選樣與 `--dependency-policy` 只適用該沙盒，不構成正式依賴翻新的決策。skill 套件只提供翻新作業規則，試用方法與結果在本目錄及獨立沙盒維護。

此目錄維護可重跑的測試程式、scenario 與 fixture。歷次 `sandbox/` 產物、報告與 `output/playwright/` 截圖已分開存入 `backup/legacy-to-spec-tests-2026-10-12` 分支；可用 `git worktree add ../FE_Modernization-test-backup backup/legacy-to-spec-tests-2026-10-12` 在新工作目錄查閱。本工作分支忽略新產生的測試記錄，保留本地檔案供後續使用。

## 案例

| 案例 | 輸入 | 要觀察的風險 |
| --- | --- | --- |
| `coupled` | 可版本管理的合成 JSP、共用片段、樣式、legacy helper 與後端契約 | 前後端映射、缺欄位／認證、JSP 業務與 session 責任、未承接需求 |
| `afy10400` | 專案真實 JSP、直接共用依賴及指定後端契約快照 | Big5、初始化、增刪列、驗證順序、實際送出資料、回應／下載及共用行為 |

合成材料只是測試用業務，不屬於 skill 的領域知識。真實輸入維持原始位元組；沒有提供的依賴仍須列為未知。

## 執行

```sh
python3 scripts/skill-sandbox.py prepare --case coupled --run <新run-id>
python3 scripts/skill-sandbox.py prepare --case afy10400 --run <新run-id>
```

新版本預設 `--stage plan`，測試單行 JSP 輸入後的計劃與任務選單；尚未選執行任務，不要求生成規格或原型。AF 部分沙盒只必須有根 JSP，缺少的共用來源與後端文件記入 manifest，不從別的分支偷偷補入。

另測交付階段時可明確加 `--stage delivery`，代表此沙盒模擬選擇所有適用 required 工作；可選提供 `--backend-root`。`--dependency-policy` 明示沙盒模擬決策：`defer` 測試引用適用契約後延後缺口；`convert-available` 測試先轉換必要且可取得依賴、不可取得者延後。預設 `ask` 不授權任何依賴翻新／延後。模擬設定不代表正式使用者授權。受控材料包含一份可引用的共用按鈕契約；其範圍及來源版本仍須核對。

每個 case 的 `task.txt` 交給獨立代理；其可讀範圍僅該 case 的 `skill/`、`inputs/` 和 manifest，輸出只寫 `artifacts/`。不要傳預期答案或先前缺陷，也不要讓生成代理自行修改評分規則。

依目前階段產出後，先執行結構檢查；只有已產出 prototype 的 delivery 階段才執行瀏覽器：

```sh
python3 scripts/skill-sandbox.py check --case-dir sandbox/legacy-to-spec/<run-id>/<case>
SKILL_SANDBOX_PLAYWRIGHT='<本機playwright-core模組入口>' node scripts/skill-sandbox-browser.mjs sandbox/legacy-to-spec/<run-id>/<case>
```

瀏覽器先產生 DOM／控制項觀察及截圖。依原始來源設計可觀察案例，將獨立的 scenario JSON 路徑作為瀏覽器腳本第二個參數再執行。它使用新暫存瀏覽器情境並阻擋 HTTP；若啟動被 macOS 沙盒限制，須透過執行環境既有的權限檢查處理，不隱藏跳過的測試。

另外由獨立審查代理讀原始材料與產物，逐項審查來源覆蓋、事實／未知、技術中立、UI／UX、API 權威、後端承接、邊界與驗證聲明，將結果寫入 case 的 `reports/semantic-review.md`。

## 修改與重測

保留每輪 skill／輸入快照、產物、報告和截圖。只依已證實失敗修正正式 skill，再以新 run ID 重新產出，不只改失敗的規格文件讓舊測試變綠。必要時先沿用既有產物做一次續作試驗，再用全新代理與全新輸出檢查修正是否有效。

結構通過不代表語意／視覺通過；沙盒 skill 表現通過也不代表實際系統已完成翻新。原始依賴、後端或 legacy 執行環境不足時，產物可以正確地是「部分交付」。

## 續作與來源檢查

`continuation/` 保留前輪產物作為不可變輸入，再由新代理依新版 skill 續作；`verification/` 使用已提供的來源審查意見進行修正並復核，屬於有審查資訊的維護回合，不列為盲測生成。兩種情況都在 manifest 記錄前輪產物／審查的 SHA-256，工作副本另放 artifacts，舊案例不修改。

來源檔案的可靠 metadata 由 skill 的 source_inventory.py 取得；不把根 JSP 的編碼／行數套到依賴。測試工具共 26 項單元測試：14 項沙盒驗證、3 項來源 inventory、6 項客製範本選用、3 項 DESIGN metadata 形狀；後者需現有 PyYAML。另外保留實際代理、來源審查及瀏覽器結果。

## 樣式與客製化試驗

`styles/coupled` 以全新 skill／來源快照盲測，額外提供 `fixtures/style-customization` 的設定與自訂文件範本。只調整文件章節，沒有批准新的產品樣式。該 profile 測試 explicit API override、custom root 的 DESIGN.md、其他角色 fallback、補充 API 撰寫規則與 `design-md+dtcg`。

生成代理從原始來源自行建立 DESIGN.md／CSS／tokens 與映射，審查代理核對來源及自訂必需資訊。瀏覽器另驗 prototype 載入後的 computed style；報告包含 CSS、DESIGN.md、tokens 的雜湊。不能用範本格式或 CSS 文字相同就宣稱像素等價。

`styles-verification/coupled` 是已提供審查意見的格式續作：保留原始 metadata 失敗，修正 typography object 與來源行號引用，CSS／HTML／JS／tokens 不變。原瀏覽器結果只在這些 byte-identical 檔案上沿用，明列繼承證據；不是另一次盲測或重跑的成功。
