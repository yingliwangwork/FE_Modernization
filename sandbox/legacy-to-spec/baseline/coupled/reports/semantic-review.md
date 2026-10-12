# Independent semantic review — coupled baseline

Reviewed 2026-10-12 after the parent confirmed generation had completed. This review first established criteria from task.txt, manifest.json, the frozen skill/SKILL.md, and the six supplied source files. It did not inspect tests/, the parent skill implementation or edits, other repositories, or the parent's browser inspection. No browser session or endpoint was opened; only this report was written.

## Result

Acceptable **partial** delivery. No critical, high, or medium semantic defect was established. One low-severity wording finding remains. The three unaccepted backend responsibilities and the unexecuted runtime checks are explicitly retained rather than concealed by synthetic success.

## Findings

### C-01 — Low: deployment absence is stronger than the supplied evidence

- Source: `inputs/backend/api-contract.md:3` says fixture-v1 is a sandbox test contract, not a formal service, and has no callable environment. It does not establish deployment status.
- Artifact: `artifacts/integration/fixture-case/api-spec.md:3` states `未部署`.
- Effect: a small factual overstatement, without changing wire definitions or claiming a usable service.
- Correction: use `部署狀態未確認；沒有提供可呼叫環境` or preserve the source wording. The surrounding source/environment qualifications are otherwise appropriate.

## Source-to-artifact assessment

| Area | Evidence and result |
| --- | --- |
| Scope and authority | Exactly `inputs/frontend/Case.jsp` is the root. Dependencies remain support sources. Tracking:9–34 records scope, hashes, missing Ledger/session/handler, and the fixture baseline. Other entry points are not renovated. |
| Triggered flows | Source JSP:19–36 clears status at search time but keeps old rows until a response; every response clears rows before branch selection. Specification:191–225 and prototype:69–109 preserve that distinction. DONE/NONE/BLOCK, their exact messages, and the known prefix for other results are kept. No invented loading, cancellation, disable, fallback, or automatic initial search is introduced. |
| UI and UX | Source JSP:48–58 plus `styles/base.css:1–4` establish title, reviewer, maxlength 12 keyword, included action bar, status, three columns, quantity form, and source CSS. Specification:87–121 and prototype:39–52/7–10 retain this order, labels, third column, styling and shared-component use. Synthetic reviewer and row values are disclosed outside the product controls. Actual rendering and native keyboard behavior remain unverified. |
| API contract | Source contract:7–26 gives `searchItems`, POST `/v2/items/search`, `queryText`, flat `outcome/rows`, `rowId/label`, and OK/EMPTY/DENIED. API spec:31–69 preserves exact names, requiredness, length 12, omitted/empty versus null, server unit context, trim mapping, empty arrays, and undefined non-200/error branches. Neither `rankHint` nor client `unitId` is added to the target schema. |
| Coupled handoff | JSP:4–9 obtains reviewer first, guards commit, parses quantity, uses threshold 4 with multipliers 8/10, then invokes Ledger.store with session unitId before rendering. Handoff:24–83 retains this ordering, trusted context, the 3→30/4→32/5→40 cases, unknown storage permanence, and missing failure/transaction semantics. Initialization and rankHint have distinct HANDOFF-01/03. Prototype:111–119 only performs the existing exact-empty guard and records a boundary; it does not parse, calculate, store, or pretend the backend has accepted the quantity. |
| Unknowns and traceability | Specification:31–40, API:90–98, and tracking:133–209 keep initialization, rankHint, quantity, identity, errors/concurrency and runtime evidence open. Tracking:74–118 maps raw symbols, branches and hidden state to neutral contracts and responsibility destinations. Links and anchors independently resolved. No unresolved template scaffold remained. |
| Claim truthfulness | Tracking:219–239 and verification.json limit all passes to static/document checks and explicitly mark browser render/interactions, console/network observation, legacy comparison, backend and Ledger verification unexecuted. Inspection supports these limits. There is no claim of pixel equivalence or deployed integration. |

## Independent checks and limits

- All 22 manifest entries still match their recorded SHA-256 values; all artifact Markdown file links and anchors resolve.
- The current prototype inline script compiled with Node `new Function`; this is syntax verification, not DOM or browser execution.
- Read the actual specification, HTML, API, handoff, tracking and generated verification record against the raw inputs. Static code has no external resource or network call and no replicated quantity calculation/storage.
- No original JSP execution, rendering, screenshot comparison, real identity context, backend call, or persistence verification was performed. The parent's separate browser observation was intentionally excluded from this independent assessment.

The unresolved backend and runtime limitations justify partial delivery; they are not evidence of fabricated completion.
