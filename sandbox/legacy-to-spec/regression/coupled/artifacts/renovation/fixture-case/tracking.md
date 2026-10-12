# fixture-case: renovation tracking

System behavior lives in [specification](../../design/fixture-case/specification.md). This document owns source analysis, evidence, TODO work, execution records and change history.

## 1. Source and boundary

| Item | Record |
| --- | --- |
| Scope ID | fixture-case; no prior artifacts or conflicting scope ID were present at start. |
| Exactly one root JSP | `inputs/frontend/Case.jsp` |
| Root SHA-256 | `90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154` |
| Encoding / line basis | UTF-8 declared and byte decoding verified; LF, no CRLF. Original file lines 1–60; no conversion or source edits. |
| Date / analyst | 2026-10-12 / Codex, isolated coupled regression case |
| Included | Full supplied root source: reviewer initialization, commit/noncommit branches, quantity parsing/tier/storage call, all visible elements, lookup trigger/callback branches, form/hidden mode, shared button, CSS and bridge. |
| Excluded | Other JSP roots, unavailable session producers/storage internals/legacy handler, parent project, other runs, external repositories and external services. No inferred runtime behavior beyond supplied facts. |
| Delivery / contract | Partial delivery, renovation-v1. Necessary target data/responsibilities and runtime checks remain open. |
| Previous record | First delivery, CHANGE-001. |
| Backend root / selected baseline | `inputs/backend`; `inputs/backend/api-contract.md`, fixture-v1, explicitly selected by task.txt (E-015). Supporting `business-rules.md` fixture-v1. |
| Source nature / environment | Backend explicitly says sandbox delivery contract, non-formal service, no callable environment. Deployment status unconfirmed. Source snapshots establish source-defined behavior, not production observations. |
| Integration artifacts | [api-spec](../../integration/fixture-case/api-spec.md), [backend-handoff](../../integration/fixture-case/backend-handoff.md). |
| Prototype | [SCR-001.html](../../design/fixture-case/prototypes/SCR-001.html) |

### Source versions and dependency stop boundary

| Source / dependency | Full SHA-256 or availability | Purpose / stopping point | Evidence / action |
| --- | --- | --- | --- |
| `inputs/frontend/Case.jsp` | `90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154` | Unique root; entire 60-line snapshot analyzed | E-001–E-006, E-008 |
| `inputs/frontend/components/action-bar.jspf` | `61f70725865ae2fc7e49b2aea291e420255f4b1e5049728fc48740431871ff9e` | Static include, button event; one-line file; no second root | E-007 |
| `inputs/frontend/legacy-bridge.js` | `f008cb043d31d427d923e66ae33e1e98c13dd1dc9dd3f668c2fd3faf72eda09a` | JSON lookup dispatch and response callback, 8 lines; stop at unavailable handler | E-014; TODO-005 |
| `inputs/frontend/styles/base.css` | `447252200c775df2b42ee0656df20334a806d91799a20602cc8f8b71d8debd99` | All four rules; no additional style dependencies | E-009 |
| `inputs/backend/api-contract.md` | `04215f381bc195b357b184c89d90e6f4fba521580feb7147c141a25cdb1ca802` | Entire fixture-v1 selected contract; exact consumer operation only | E-010–E-012 |
| `inputs/backend/business-rules.md` | `35e4253d281cacc662c065ed690337ae8a71f04233df8289c065828aba7614b7` | Entire 6-line responsibility document; no invented transport semantics | E-013 |
| `example.Ledger` | Not supplied; root import/call only | Actual persistence, error and transaction semantics unconfirmed; do not search outside case | E-002; TODO-003/005/008 |
| `/legacy/searchRows` handler | Not supplied; bridge URL only | Legacy service internals unknown; selected target mapping governs API projection | E-014/E-012; TODO-005 |
| Session producers of `reviewerLabel` / `unitId` | Not supplied | Trust provenance, values and null handling unconfirmed | E-001/E-002; TODO-001/004 |

All 22 manifest-listed input/skill files matched supplied SHA-256 on initial read. Actual input byte encodings were readable UTF-8 with LF. The skill's backend-reference document is method context only; its external project paths were not inspected, queried or adopted as authority.

## 2. Renovation plan

| Work | Completion criterion | Status | Record |
| --- | --- | --- | --- |
| W-001 source/baseline lock | Manifest hashes, encoding, root, selected backend, boundaries identified | Complete | V-001, E-015 |
| W-002 analysis/decomposition | Every supplied event/branch/context/side effect has mapping or TODO | Complete for supplied snapshots | Coverage and LOGIC tables below |
| W-003 specification/projection/handoff | Separate artifacts with evidence, original sequence and explicit unknowns | Complete as partial contracts | Five primary artifact files; V-002 |
| W-004 offline prototype | Known controls and callbacks, source style, review tools separate; no external calls or backend arithmetic | Complete as local demonstration | V-003/004/005; browser review pending |
| W-005 runtime/visual/integration verification | Actual browser, legacy baseline and backend comparison with environment/evidence | Not executed; parent independently handles browser scenarios; no environment supplied for legacy/backend | TODO-006, V-006/007 |

## 3. Evidence register

Versions are the full SHA-256 values in §1. All code evidence below is source-defined behavior, not observed running production behavior.

| Evidence | Type / source / original lines | Minimal fact | Supported contract / limits |
| --- | --- | --- | --- |
| E-001 | Root JSP 3–4 | `reviewerLabel` read from session before branch | DATA-001/FLOW-001/BOUND-003/HANDOFF-001; no producer or missing-value observation |
| E-002 | Root JSP 5–9; import line 2 | When `mode=commit`, `Integer.parseInt(quantity)`; `quantity >= 4 ? quantity * 8 : quantity * 10`; `Ledger.store(session unitId, quantity, charge)` | FLOW-005, DATA-008–011, BR-004/HANDOFF-003; call not proof of persistence; Ledger absent |
| E-003 | Root JSP 11–17, 47–53 | Chinese title/heading, reviewer line, keyword maxlength 12, status, three table headers | SCR-001/UI-001–009, DATA-002, initial structure; not a rendered screen observation |
| E-004 | Root JSP 19–23 | Clear status; trim filter; dispatch; existing rows cleared only within callback | FLOW-002/BR-001/002/ST-002; no retry/timing guarantee |
| E-005 | Root JSP 23–36 | Clear body; DONE inserts key/text/rankHint; NONE → 沒有項目; BLOCK → 不允許查閱; no other branch | FLOW-003/TR-003–006/MSG-001/002, row order; no defined malformed/transport failure behavior |
| E-006 | Root JSP 38–44 | Exact-empty quantity alert 數量不得為空 and false; other input true | FLOW-004/BR-003/TR-007/008/MSG-003; no numeric or positive screen check |
| E-007 | Include line 1; root JSP 51 | Button 查閱 calls searchRows within action-bar | CMP-001/UI-004/FLOW-002; this use only |
| E-008 | Root JSP 54–58 | POST form with no explicit action, hidden mode=commit, quantity text, submit 送出數量 | FLOW-004/BOUND-002/DATA-011/UI-010/011; same-document legacy submission, no completion contract |
| E-009 | CSS lines 1–4 | sans-serif, max-width 720px, margin24px, #222; collapsed width100% table margin16px0; #555 border, padding6px left; action margin-top8px | Source visual structure/CMP-001; no pixel/viewport observation |
| E-010 | API contract lines 3, 7–12 | fixture-v1/non-formal/no environment; searchItems; POST /v2/items/search; JSON; optional queryText max12, missing/empty unspecified, null invalid; server unit, client unitId not accepted; auth undefined | API-001 request/context; no deployment inference |
| E-011 | API contract lines 16–19 | HTTP200 root outcome/rows required; OK/EMPTY/DENIED; rows rowId/label required; EMPTY/DENIED rows=[]; other responses undefined | API-001 full known envelope; no other fields inferred |
| E-012 | API contract lines 23–27 | Explicit searchRows→searchItems; search_word→queryText, trim applicable; DONE/NONE/BLOCK→OK/EMPTY/DENIED; itemList/key/text→rows/rowId/label; rankHint/reviewer/quantity not carried | Target/legacy mapping and HANDOFF-001–003; only explicit equivalences |
| E-013 | Business rules lines 3–6 | fixture-v1 lookup only; server unit permission; permission/no matches outcomes; sorting/paging/retry/cancel/transaction/billing/storage undefined | Backend lookup responsibility; no extra guarantees |
| E-014 | Bridge lines 1–8 | fetch POST /legacy/searchRows JSON parameters, response.json then receive; no explicit catch | Legacy boundary transport/source dependency; absence of catch does not prove visible error outcome |
| E-015 | task.txt and manifest.json, frozen case instructions | Root Case.jsp, fixture-case, selected API contract, snapshot-only isolated scope | Source selection/scope constraints, not product behavior |

## 4. Source-to-contract coverage

Every item below is mapped, explicitly unconfirmed, or a scope boundary. This inventories supplied snapshots only; unavailable dependency internals are not counted as covered.

| Source item / original lines | Fact type / evidence | Neutral contract | Prototype / cases | Conclusion |
| --- | --- | --- | --- | --- |
| Root 1, 11–17 | Encoding/language/title/resources; E-003/E-015 | SCR-001/UI-001 | SCR-001.html / AC-001 | UTF-8 and source resource dependencies recorded |
| Root 2–4 | Trusted initialization/import; E-001/E-002 | DATA-001/FLOW-001/BOUND-003 | UI-002 / AC-001 | HANDOFF-001/TODO-001/004; Ledger boundary recorded |
| Root 5, 9 | Commit vs noncommit; E-002 | DATA-011/FLOW-005/TR-009 | No backend execution / AC-009/010/014 | HANDOFF-003/TODO-003 |
| Root 6 | Parse quantity; E-002 | DATA-008/FLOW-005 | Boundary only / AC-008–010 | Backend parsing; missing error outcome TODO-003/005 |
| Root 7 >=4 branch | Charge quantity×8; E-002 | DATA-009/BR-004/HANDOFF-003 | No local arithmetic / AC-010 | Backend responsibility |
| Root 7 <4 branch | Charge quantity×10; E-002 | DATA-009/BR-004/HANDOFF-003 | No local arithmetic / AC-009 | No new positivity constraint |
| Root 8 | Trusted unit/storage call; E-002 | DATA-010/BOUND-002/HANDOFF-003 | No real writes / AC-009/010 | TODO-003/004/008 |
| Root 16 + CSS 1–4 | Source styles; E-009 | SCR-001/CMP-001, spec §4.3 | Source rules in HTML / AC-001 | Structural match; browser/pixel checks TODO-006 |
| Root 17 + bridge 1–8 | Lookup adapter boundary; E-014 | BOUND-001/API-001 | Local fixture dispatch only / AC-002 | Legacy handler unavailable; selected target E-012 |
| Root 19–21 | Trigger/status clear/trim; E-004 | FLOW-002/DATA-002/003/TR-002 | UI-003/004/005/ST-002 / AC-002/011 | Keyword remains unchanged in input |
| Root 22–23 | Callback row clear; E-005 | FLOW-003/BR-002 | UI-009 / AC-003–006/012 | Applies before every recognizable or other result branch |
| Root 24–30 | DONE / item order/key/text; E-005 | DATA-004/005/007/TR-003/ST-003 | UI-006/007/009 / AC-003/013 | API-001 confirmed mapping E-012 |
| Root 29 | rankHint display; E-005 | DATA-006/UI-008/HANDOFF-002 | Static legacy sample; target gap / AC-003/013 | TODO-002, no target schema extension |
| Root 31–32 | NONE; E-005 | TR-004/ST-004/MSG-001 | UI-005 / AC-004 | Maps EMPTY E-012 |
| Root 33–34 | BLOCK; E-005 | TR-005/ST-005/MSG-002 | UI-005 / AC-005 | Maps DENIED E-012 |
| Root 24–35 unmatched | Other legacy result; E-005 | TR-006/ST-006 | Local OTHER fixture / AC-006 | Legacy known no-op after clear; target codes undefined |
| Root 19–36 + include | Repeated lookup/no guard; E-004/E-005/E-007 | FLOW-002/003, spec callback status rule | Held callbacks / AC-012 | No race guard introduced; guarantees TODO-005/008 |
| Root 38–41 | Exact empty validation/alert/false; E-006 | BR-003/FLOW-004/TR-007/MSG-003 | Native alert/UI-012/ST-007 / AC-007 | Existing search content retained |
| Root 43 | Nonempty true; E-006 | FLOW-004/TR-008/ST-008 | Boundary log only / AC-008 | Whitespace/nonnumeric pass frontend, not backend validity |
| Root 48–50 | Heading/reviewer/keyword; E-003 | UI-001–003/DATA-001/002 | Synthetic reviewer/real limit / AC-001/011 | Initialization target TODO-001 |
| Root 51 + include 1 | Shared action-bar; E-007/E-009 | CMP-001/UI-004 | data-component-id / AC-002 | This root use only |
| Root 52–53 | Status/table headers/initial empty body; E-003 | UI-005–009/ST-001 | Initial empty screen / AC-001 | No synthetic initial result inserted |
| Root 54–55 | POST same-document/hidden mode; E-008 | BOUND-002/DATA-011 | Hidden input retained; submission prevented for review / AC-008 | No client unit hidden field added |
| Root 56–57 | Quantity text + button; E-008 | UI-010/011/FLOW-004 | Same control types/order / AC-007/008 | No numeric conversion or charge display |
| Selected API 7–19, 23–27 | Full exchange/mapping/gaps; E-010–012 | API-001/BOUND-001/TR-003–005 | Target rows only known fields / AC-013 | Explicit ranking/reviewer/quantity gaps |
| Business rules 5–6 | Lookup auth/business/undefined guarantees; E-013 | BR-005/BOUND-001 | No authorization computation | TODO-004/008 |

### 4.1 Mixed responsibility inventory

| Logic / source | Trigger, data and original order | Condition/result | Responsibility | Contract and backend coverage | Gap |
| --- | --- | --- | --- | --- | --- |
| LOGIC-001 root4, E-001 | All entry: get session reviewer before commit check | Dynamic reviewer later rendered | Trusted context | FLOW-001/DATA-001; E-012 not carried | HANDOFF-001/TODO-001/004 |
| LOGIC-002 root5, E-002 | After reviewer get, inspect request mode | Only exact commit enters next steps | Action selection/backend lifecycle | FLOW-005/DATA-011; target not carried | HANDOFF-003/TODO-003 |
| LOGIC-003 root6, E-002 | Commit: parse quantity before charge | Integer parsing; errors not handled locally | Business data interpretation | FLOW-005/DATA-008; no target adoption | HANDOFF-003/TODO-003/005 |
| LOGIC-004 root7, E-002 | Parsed quantity → threshold → charge | >=4 ×8, otherwise ×10 | Business calculation | DATA-009/BR-004; E-012/013 exclude quantity | HANDOFF-003/TODO-003 |
| LOGIC-005 root8, E-002 | After charge: get trusted unit, call storage | unit/quantity/charge passed; no result consumed | Trusted context + external write request | DATA-010/BOUND-002; no adoption | HANDOFF-003/TODO-003/004/008; Ledger missing |
| LOGIC-006 root48–53/56–57, E-003/E-008 | After backend entry path returns, render labels/data/controls | Visible source order | Presentation | SCR-001/UI-001–011 | Missing reviewer/hint target inputs kept separate |
| LOGIC-007 root19–21, E-004 | Click → clear status → trim/read → dispatch | Preserve existing rows until callback | Presentation/input transform + boundary dispatch | FLOW-002/DATA-003/API-001 adopted by E-010/E-012 | Auth/failure TODO-004/005 |
| LOGIC-008 root23–35, E-005 | Callback → clear rows → select result → insert cells or message | Key/text/rankHint and result messages | Presentation and known data rendering | FLOW-003/UI-005–009; API-001 maps key/text/result E-011/012 | HANDOFF-002/TODO-002 for hint |
| LOGIC-009 root38–44, E-006 | Submit → exact-empty check → alert/false or true | Empty blocked, other text permitted | Frontend operation constraint | FLOW-004/BR-003/MSG-003 | Does not replace trusted backend validation |
| LOGIC-010 root54–55 + bridge, E-008/E-014 | Form sends commit/quantity; search bridge posts JSON and decodes response | Two distinct boundaries; no transaction relation evidenced | Boundary exchange | BOUND-001 API-001; BOUND-002 handoff | HANDOFF-003; TODO-005/008 |
| LOGIC-011 include/CSS, E-007/E-009 | Render action-bar shared button with source spacing | Lookup event | Shared presentation/experience | CMP-001 | No cross-page inference |
| LOGIC-012 selected business E-013 | Server unit → permission → no/matching results | DENIED/EMPTY/OK | Backend authorization/retrieval | BR-005/BOUND-001/API-001 | Context provenance/transport TODO-004 |

### 4.2 API and adoption tracking

| Boundary / projection / handoff | Reviewed baseline | Mapping / gap | Status / resolution |
| --- | --- | --- | --- |
| BOUND-001/API-001 | Selected fixture-v1 E-010–013 | queryText/outcome/rows/rowId/label explicit; server unit; no target hint | Document comparison completed; integration unexecuted; TODO-002/004/005/008 |
| BOUND-003/HANDOFF-001 | E-012 explicitly omits initialization | Reviewer source not adopted | Open TODO-001; no adoption evidence |
| DATA-006/HANDOFF-002 | E-011/E-012 row schema excludes hint definition | Known legacy display remains needed | Open TODO-002; static sample not adoption |
| BOUND-002/HANDOFF-003 | E-012/E-013 omit quantity | Tier/storage/context/error/transaction unknown target | Open TODO-003/004/005/008; no local implementation |

## 5. TODO and contract gaps

### TODO-001

- Type/status: missing target initialization and dependency, open.
- Question: how is a legitimate trusted reviewer value delivered for entry, including missing/null value handling?
- Known: session read precedes render (E-001/E-003); selected baseline does not carry it (E-012).
- Impact: FLOW-001, BOUND-003, DATA-001, UI-002, AC-001, HANDOFF-001.
- Next action: obtain supplied session producer/initialization contract and missing-value evidence; do not query external systems under this run.
- Close only with target adoption source, updated mappings and applicable recorded verification. Resolution: none.

### TODO-002

- Type/status: frontend/selected-backend capability gap, open.
- Question: how is per-item ranking hint carried, or what explicitly confirmed change replaces the visible third column?
- Known: legacy rankHint rendered (E-005); selected rows define rowId/label only and explicitly omit hint (E-011/E-012). No numeric sorting rule established.
- Impact: FLOW-003, DATA-006, UI-008, ST-003, AC-003/013, HANDOFF-002.
- Next action: obtain a selected target coverage record or approved visible-contract decision; never infer rank from list position.
- Close with field/semantic source or confirmed change plus contract/prototype/API updates and verification. Static synthetic hint/blank target cell does not resolve it. Resolution: none.

### TODO-003

- Type/status: uncarried backend responsibility / absent dependency, open.
- Question: how will quantity parsing, >=4 tier pricing and unit/quantity/charge storage be adopted, and what is its observable outcome?
- Known: E-002 shows parse/tier/store before render; E-006 only checks empty client input; E-012/013 exclude quantity; Ledger source absent.
- Impact: FLOW-004/005, BOUND-002, BR-004, DATA-008–011, AC-008–010/014, HANDOFF-003.
- Next action: obtain supplied Ledger contract and target adoption artifact, including parsing/storage outcomes. No invented commit endpoint.
- Close with explicit adoption covering input/condition/order/output/side-effect semantics plus recorded checks. Resolution: none.

### TODO-004

- Type/status: trusted-context and authentication contract unknown, open.
- Question: how are unit/reviewer context established, and what authentication transmission does API-001 require?
- Known: legacy session values E-001/E-002; selected search unit is server context and client unitId prohibited; authentication undefined E-010/E-013.
- Impact: BOUND-001–003, DATA-001/010, API-001, HANDOFF-001/003.
- Next action: obtain legitimate context/authentication delivery artifacts in a later supplied snapshot.
- Close with authority-backed source/transport and affected mappings, with necessary verification. No editable unit, invented header/token/session copy. Resolution: none.

### TODO-005

- Type/status: external failure/error and asynchronous guarantee unknown, open.
- Question: what are non-200, decoding/malformed response, callback exception, parse/storage error and request-order outcomes?
- Known: bridge has response.json/receive but no explicit catch E-014; callback branches E-005; selected baseline defines HTTP200 known results only E-011; commit has no local exception handler E-002.
- Impact: FLOW-002/003/005, BOUND-001/002, AC-006/012, API-001, HANDOFF-003.
- Next action: obtain supplied error/common response/exception and relevant runtime observations. Do not replace with generic success/failure messages.
- Close each supported branch separately with evidence and updated mapping/checks. Resolution: none.

### TODO-006

- Type/status: runtime/visual/integration checks not executed, open.
- Question: do source reconstruction and local controls behave in an actual browser, and how do they compare with legacy display and real backend?
- Known: only raw snapshots and local static/VM checks are available; parent handles browser independently. No legacy/browser/backend execution claimed here.
- Impact: SCR-001, all cases, V-006/007; necessary validation prevents complete delivery.
- Next action: parent may execute local browser scenarios; future supplied legacy environment/screenshots and backend environment required for their respective checks.
- Close each check with environment, role/data, operations, actual observations and screenshot paths where applicable. A browser prototype pass does not verify backend or legacy visual parity. Resolution: none.

### TODO-007

- Type/status: experience details unknown, open.
- Question: what are intended focus, shortcut, tab/keyboard activation, cancel/back, viewport and zoom behaviors?
- Known: supplied CSS E-009 and source controls establish structure; no custom focus/keyboard/cancel/back contract given.
- Impact: SCR-001/spec §4.3, browser validation.
- Next action: obtain scoped runtime observations or confirmed behavior record. Do not turn review-control keyboard semantics into product requirements.
- Close with supported observations/decisions and matching contract/prototype updates/checks. Resolution: none.

### TODO-008

- Type/status: service and transaction guarantees undefined, open.
- Question: sorting/pagination/retry/idempotency/timeout/cancel/transaction/rollback or relationship between search and quantity operations?
- Known: E-013 says these are not defined; E-002 shows one storage call, E-005 displays received order. Absence of guarantee is not permission for partial success.
- Impact: API-001, BOUND-001/002, HANDOFF-003, FLOW-005, AC-012.
- Next action: obtain applicable backend guarantees and storage semantics from supplied sources; no client compensation design.
- Close with responsibility-specific evidence and necessary validations. Resolution: none.

### TODO-009

- Type/status: business intent/role context unconfirmed, open.
- Question: who uses this screen, for what broader business purpose, and what does a quantity/charge represent?
- Known: labels and observed source actions E-003/E-006/E-007/E-008; no intent or role document supplied.
- Impact: specification purpose/actor semantics; no invented INT IDs or currency unit.
- Next action: obtain authority-backed intent/role/domain documentation for this entry.
- Close with precise scope/role/intent evidence and updated relevant contract; not by naming inference. Resolution: none.

## 6. Original concerns and proposed changes

| Source-defined concern | Evidence | Candidate change | Decision / contract effect |
| --- | --- | --- | --- |
| Exact-empty quantity check lets whitespace/nonnumeric input pass locally | E-006 | Additional numeric/domain validation | Not authorized/confirmed; not added. Backend errors remain unknown TODO-003/005. |
| Overlapping callbacks can leave prior status alongside later success rows | E-004/E-005 | Reset status on every callback or latest-response filtering | Not authorized/confirmed; original callback sequence retained and locally demonstrated AC-012. |
| Legacy bridge has no explicit catch/error UI | E-014 | Defined failure messages/retry | No confirmed error contract, no product message added; TODO-005. |

These are source concerns, not claimed production defect observations. No product improvement is assumed approved.

## 7. Validation execution and delivery decision

| Validation | Check / environment and action | Actual result / record | Status / limit |
| --- | --- | --- | --- |
| V-001 | Python3, isolated case; all 22 manifest files SHA-256, UTF-8/LF, original line counts | All 22 hashes matched; root 60 lines, UTF-8, zero CRLF; no source edits | Passed source integrity; not runtime evidence |
| V-002 | Source/contract comparison; Node local-checks.mjs static artifact ID/link/anchor/placeholder checks | Five primary artifacts have no template placeholders; relative links/anchors exist; DOM/script IDs map to spec and HTML IDs are unique. Source/selected API facts compared as mapped above. [check report](local-check-results.txt) | Passed document/static checks; no runtime or full-contract completion claim |
| V-003 | Node --check on extracted actual inline prototype script, run by local-checks.mjs | Exit 0, no syntax errors reported; [report](local-check-results.txt) | Passed syntax; not browser compatibility |
| V-004 | Node VM, minimal DOM test doubles, actual inline script; synthetic fixtures and submit events; no user role/auth context | AC-002/003/004/005/006/007/008/012/013 script branches passed: trim/status/retained rows, returned order, empty/denied/other, quantity guard, overlap status, target hint gap; review reset passed. [script](local-checks.mjs), [actual report](local-check-results.txt) | Passed local script checks only; no native browser alert/maxlength/layout check, no backend execution; AC-001/009/010/011/014 not fully executed |
| V-005 | Static prototype resource/API scan and repeated frozen manifest hash verification | No external resource tags, fetch/storage APIs, charge arithmetic or Ledger invocation found in actual prototype; all 22 manifest hashes still matched. [report](local-check-results.txt) | Passed scoped static/integrity checks; no observed browser network claim |
| V-006 | Actual browser opening, events/native maxlength/focus, screenshots/console/connection inspection | Not executed by this agent, as requested; parent performs independent browser scenarios | Unexecuted, TODO-006/007 |
| V-007 | Running legacy page/pixel comparison, target/backend integration/storage and trust checks | No environment provided, no network/backend calls allowed or performed | Unexecuted, TODO-001–008 as applicable |

### Delivery conclusion

- Confirmed scope: all supplied source-defined screen structures, events and identifiable branches are represented in source coverage, flows and acceptance definitions. One root only; dependencies are supporting evidence. V-001–005 verify supplied hash integrity, artifact references/IDs, script syntax and the expressly listed local script branches. Actual report: [local-check-results.txt](local-check-results.txt).
- Unknown dependency internals and unavailable target coverage remain explicit. No coverage percentage is claimed and no unavailable dependency is assumed complete.
- Browser, legacy display and backend integration have not been verified. Source-defined expected cases remain separate from actual execution records.
- Partial delivery: open necessary reviewer/hint/quantity/context/failure gaps and missing runtime validation prevent declaring renovation complete.

## 8. Incremental record

| Change / date | Source baseline | Evidence / artifact change | TODO change | Validation |
| --- | --- | --- | --- | --- |
| CHANGE-001 / 2026-10-12 | First manifest-pinned snapshot, selected fixture-v1 | E-001–015; specification, SCR-001 prototype, API-001 and HANDOFF-001–003 created; original stable IDs assigned | TODO-001–009 opened; none closed | V-001–005 executed, with actual local-check-results.txt; V-006/007 unexecuted |
