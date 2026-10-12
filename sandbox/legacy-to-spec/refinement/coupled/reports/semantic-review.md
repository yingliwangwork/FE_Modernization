# Independent semantic review: refinement / coupled

Reviewed 2026-10-12. Scope: this case's `task.txt`, `manifest.json`, `skill/`, `inputs/`, and `artifacts/` only. No evaluation browser suites, other case outputs, previous reports, parent conclusions, network calls, or legacy execution were used. Only this report was added; generated artifacts and snapshots were not edited.

**Verdict: substantially faithful partial delivery, with two localized generated-document defects.** No invented target operation, backend schema, quantity calculation in the prototype, persistence guarantee, or claim of real integration was found. Necessary external and browser gaps remain open, as the delivery correctly states.

## Generated defects

### SR-01 — Deferred gaps are not linked at every affected contract location (medium)

Affected file: `artifacts/design/fixture-case/specification.md`.

- Lines 35–37: DATA-06 explicitly says backend parsing rules and exceptions need adoption; DATA-07 gives the unadopted calculation; DATA-08 says the quantity write's trusted source has not been adopted. None of these rows identifies or links TODO-03.
- Line 71: ST-03 acknowledges the third-column target-data gap but does not identify or link TODO-02.
- Line 75: ST-07 says backend completion/exceptions need adoption but does not identify or link TODO-03.

The missing target capability is **not** itself a generated defect. Source evidence is `inputs/backend/api-contract.md:27` (rankHint, reviewer initialization, and quantity submission not adopted), `inputs/backend/business-rules.md:6` (quantity charging/storage not defined), and `inputs/frontend/Case.jsp:5–8,25–29` (known old behaviors). TODO-02/03 are present in tracking and linked from the main flows and boundaries. However, an implementer reading the affected data/state row cannot follow its local gap to the decision and work item. This falls short of `skill/SKILL.md:47,85`, `skill/references/dependencies.md:26`, and the affected-position requirement in `task.txt:7`.

Correction: put TODO-03 links on DATA-06/07/08 and ST-07 and a TODO-02 link on ST-03. Existing tracking entries already link to TASK-08/09 and DEC-01; no new dependency decision or backend invention is needed.

### SR-02 — API acceptance reference claims cases absent from the referenced definition (low)

Affected file: `artifacts/integration/fixture-case/api-spec.md:69`.

The API document says AC-02 checks trim, empty string, length 12, and illegal null and says the definitions are in frontend specification section 8. But `artifacts/design/fixture-case/specification.md:131` defines AC-02 only for the input `  示範  ` with existing rows/status. There is no AC-02 empty, 12-character boundary, over-limit, omitted-field, or null case there. `artifacts/renovation/fixture-case/checks/prototype.js:26–31` likewise executes only the trim/status/old-row case. The API facts themselves are faithful to `inputs/backend/api-contract.md:10,24`; the defect is the reference/coverage claim, not the wire contract.

Correction: define distinct contract-only boundary cases with concrete inputs/expected interpretations, or narrow the AC-02 reference and clearly identify which API constraints are only source-checked. Actual service acceptance must remain unexecuted without an environment. Existing V-03/results correctly label their executed subset, so this does not justify alleging fabricated real backend testing.

## What passed the source-to-artifact review

| Concern | Assessment and evidence |
| --- | --- |
| Single root and scope | Exactly `inputs/frontend/Case.jsp` under `fixture-case`; dependencies remain supporting evidence, not a second renovated entry. Plan lines 5–7; tracking lines 7–9,22. |
| Plan-before-analysis record | Plan preserves the initial pending inventory (lines 3–30), then explicit P1/P2 update (lines 32–46), then later task states (lines 66–70). This is an adequate document record. Actual historical ordering cannot independently be proved from final files alone; the audit does not certify shell/session chronology. |
| Tasks, dependencies and impact | TASK-01–06 have dependencies, affected outputs and completion/verification conditions. TASK-07–10 specify prerequisite evidence/environment, affected contracts and revalidation. Plan lines 13–20,50–64. |
| Suitable contract reuse | Action-bar source hash matches its existing fixture-component-v1 contract and manifest. Reuse is limited to CMP-SEARCH-ACTION and this page's callback; no query/results responsibilities are attributed to the component. Inputs action-bar.md lines 3–11; plan line 38; specification line 63. |
| Simulated dependency decision | DEC-01/02 explicitly use task.txt's simulated reuse/defer authorization and distinguish it from formal project decisions. Missing style/bridge/Ledger/context/old responder contracts stay open. Plan lines 26,38–46; tracking lines 98–120. |
| Source factualness and behavior coverage | Initialization captures reviewer name before commit handling; commit/noncommit branches, integer parsing, threshold calculation, trusted unit write call and later rendering are retained. Query initiation clears status before trim/dispatch and retains old rows until callback. Every callback first clears rows; success builds three columns, empty/denied show exact messages, other legacy results retain prior status. Quantity guard rejects only exact empty string. Source Case.jsp lines 4–9,19–44,47–58; specification flows 01–05 and tracking coverage/LOGIC tables. |
| Time/order and concurrency | Repeated lookup is allowed. Later successful callbacks do not clear text set by another callback. No latest-request-only filtering, cancellation or debounce was added. Source Case.jsp lines 19–36; specification lines 88,110–116; prototype lines 70–96. |
| Neutral front-end contract | Main behavior uses semantic data, actors, state, flow and boundary IDs. Exact target method/path/wire fields live in the API projection. Technical source symbols principally live in evidence/tracking; no framework or storage design is prescribed. |
| UI/UX and prototype | Labels, three headers, component action, quantity text field, native empty alert, ordering and four supplied CSS rules are preserved. Review controls and synthetic name/rows/third column are clearly labeled and can be hidden. Prototype does not call a service, execute Ledger, calculate charges or manufacture a successful quantity result. Prototype lines 7–15,19–48,102–123. Rendering equivalence is explicitly unverified. |
| Authority and API projection | Correct selected fixture-v1 baseline, source character, environment limit, exact POST path, JSON, optional string queryText/max12/null prohibition, server-provided unit and all known response fields/results. Explicit backend legacy mapping supports the projection; rankHint is not added to target rows. API spec lines 5,22–61; inputs backend contract lines 3–27. |
| Backend handoff | Three evidence-based handoffs cover reviewer initialization, quantity parsing/calculation/trusted context/write/order and missing third-column source. No new endpoints, client-computed fees or client-entered trusted context. A Ledger invocation is distinguished from proof of persistence/transactions. Handoff lines 13–50. |
| Separation and follow-up | Source coverage, LOGIC ownership, decision, TODO status and V results remain in renovation tracking; system behavior and case definitions remain in design/integration. Existing TODO entries have evidence, next steps, affected IDs, closure conditions and plan-task links. Local omissions are SR-01. |

## Open external gaps and limits, not generated defects

- TODO-01 / HANDOFF-01: target reviewer-name initialization, legal source, missing/null/error behavior.
- TODO-02 / HANDOFF-03: target ordering-hint source/type/empty semantics or an authorized visible-behavior change.
- TODO-03 / HANDOFF-02: quantity operation, trusted unit mechanism, Ledger internals, parse/write error behavior and transaction/retry guarantees. The source proves the old call/calculation sequence, not target adoption or durable storage.
- TODO-04: authentication transport, non-200/unknown result behavior, field-null/error details and callable environment. Deployment is unconfirmed; lack of an environment is not proof of nondeployment.
- TODO-06: independently maintained suitable style/bridge contracts. Limited page-specific source inventory and retained visual facts do not claim these dependencies have been independently renovated.
- TODO-05: actual browser rendering, native-dialog presentation, focus/keyboard behavior, console/network observation and legacy visual comparison. No source-only review can certify pixel equivalence. The artifact records these as unexecuted rather than reporting false passes.

## Independent reproduction of the claimed artifact checks

Executed from this case directory, without network or legacy execution:

1. `python3 artifacts/renovation/fixture-case/checks/static.py` — exit 0. All manifest snapshot hashes matched; UTF-8/LF and documented structural/link/identifier/static-token checks passed.
2. `node artifacts/renovation/fixture-case/checks/prototype.js` — exit 0. Generated prototype JavaScript ran against its minimal fake DOM; local callback order/status retention, synthetic rows, empty-alert invocation, nonempty boundary and review controls passed.

Results match `artifacts/renovation/fixture-case/checks/results.txt:1–8` and tracking V-01–03. These checks establish their narrow static/fake-DOM scope only; the report does not enlarge them into browser, legacy or real backend validation. V-04's manual source comparison was independently repeated by this audit. Claims of historical plan creation and the original browser-tool availability probes cannot be independently reconstructed from the final artifact files, so they remain documentary assertions rather than reproduced execution evidence.
