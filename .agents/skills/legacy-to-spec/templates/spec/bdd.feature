# 模板填寫提示（產出時移除）
# - 職責：記錄有證據的可觀察行為情境，不管理任務、案件狀態或實測結果。
# - 填寫：依 guides/customization.md 的「模板填寫規則」；本骨架沒有產品 scenario。
# - Scenario：使用英文 Given/When/Then，前置、觸發、結果皆需有證據。
# - Tags：@scope_<scope-id> @AC_<id> @FLOW_<id> @E_<id>；可重複 E tag。
# - 追溯：ID 與版本對應 PRD／UI/API spec 及真實 history/evidence，不引用空骨架。
# - 未知：保留 TODO 註解／限制與索引連結，不放入 executable steps 或假成功 Background。
# - 實測：V-ID、環境、資料、pass/fail/not-run 與 log 另留 history/review。

@template_only @evidence_pending
Feature: Evidence-backed behavior for {{scope-id}}
  Status: template scaffold; no completed product behavior or test result.
  Source: {{root-entry-path-and-version}}
  Evidence registry: {{history-evidence-location}}
  Review record: {{history-review-location-and-spec-version}}
  Applicable contracts: {{PRD-US-UC-and-UI-API-references}}
  Known limitations: {{TODO-IDs-and-affected-contracts}}
