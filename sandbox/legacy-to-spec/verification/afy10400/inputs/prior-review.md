# Independent semantic review: refinement / AFY10400

Reviewed 2026-10-12. Read only this case's skill, inputs, manifest, task and artifacts. No browser suites, evaluation reports, other cases/conclusions, parent findings, external originals, network, legacy execution or backend execution were used. Artifact/snapshot writes were suppressed during check reproduction; only this report was added.

**Verdict: useful, substantially source-based partial delivery, with six concrete generated defects.** The major root interactions, API authority, backend handoffs, simulated dependency decision, bounded support contract and verification limits are preserved. The defects below concern source-record accuracy, a missing known response branch, message-window behavior, a supplied CSS cascade rule, neutrality and local TODO links. These are distinct from the legitimate unresolved host/backend/browser gaps.

## Generated defects

### AF-SR-01 — date.js source metadata and clean-decoding claims are false (medium)

Affected positions:

- `artifacts/renovation/AF-AFY10400/source-inventory.json:102–108`: date.js is recorded as CP950 with 1,430 lines.
- `artifacts/renovation/AF-AFY10400/tracking.md:9`: specifically says date.js is UTF-8.
- Tracking V-01 at line 136 describes decoding/checking all 16 source snapshots and treats encoding/line references as verified.

Independent byte checks of `inputs/frontend/sourceCode/CM/js/date.js` show **1,089 lines** (1,088 CRLF pairs), not 1,430. Strict CP950 fails at byte offset 40 (`8e cd` in original line 3); strict UTF-8 fails at offset 8. Big5 and Big5-HKSCS also fail at offset 40. Its hash nevertheless exactly matches manifest. Therefore neither recorded encoding claim is a reproducible full decoding, and the line count appears copied from calendar.js's different 1,430-line snapshot.

The unreadable/nonconforming input bytes are an input limitation; the generated defect is falsely recording a resolved encoding/line basis rather than the limitation. The root JSP itself correctly decodes as CP950, has 246 original lines and 246 CRLF pairs; this finding does not invalidate its labels.

Correction: retain the input bytes, correct date.js's byte-line count, record the precise decode failure/affected comment location and any explicit lossy or partial analysis method. Do not infer the intended damaged text. Narrow V-01 to the properties actually verified. `static_check.py:38–40` checks hashes and stored flags, not encoding/line correctness, so its pass cannot support the erroneous metadata. Relevant requirement: skill source-analysis lines 7–9 and evidence requirements for original line bases.

### AF-SR-02 — Registered exception alert branch is omitted from the support/root contract (medium)

Affected positions: `artifacts/design/AF-AFY10400-support/contract.md:27–35` (CMP-03); `artifacts/design/AF-AFY10400/specification.md:124–126,144–146,167` (FLOW-04/FLOW-09/AC-14); tracking coverage at lines 62 and 144.

Source evidence:

- `inputs/frontend/sourceCode/CM/js/ajax/CSRUtil.js:684–692` defines `onException`: it constructs an **original native alert** beginning `Error :\n`, followed by `url : `, `\nparams: `, `\nException: \n` and enumerated exception properties.
- CSRUtil lines 2620–2637 register its default responder for the Prototype route used by the root.
- `inputs/frontend/sourceCode/CM/js/ajax/prototype.js:1942–1950,1959–1964,1994–1996` catches callback/responder errors and dispatches that exception event. Root `AFY10400.jsp:99–103,108–111` contains operations that can throw on malformed response maps.

The output describes business success/failure, missing JSON, text-response fallback and system-specific messages, but not this known callback/processing exception reaction. FLOW-04 mentions that malformed data may throw and calls a safe fallback unconfirmed. A new safe fallback is indeed unconfirmed; the existing diagnostic alert reaction is directly available source evidence and should not disappear with it. Coverage cannot treat all related response branches as accounted for while omitting this one.

Correction: give this branch an evidence-backed message/transition/case and map its diagnostic dynamic fields without inventing target-backend error behavior. Preserve the catch → diagnostic alert → subsequent lifecycle processing distinction established by source, or explicitly leave only its actual browser execution unverified. This requires no external service. Skill source-analysis line 11, evidence conditional-branch rules and acceptance source-coverage criteria apply.

### AF-SR-03 — Message-window empty and accumulated-message behavior drifts (medium)

Affected positions: `artifacts/design/AF-AFY10400/prototypes/SCR-01.html:93–98`, CMP-04 support at `artifacts/design/AF-AFY10400-support/contract.md:39–43`, and FLOW-09/AC-10.

Source evidence: `CSRUtil.js:1592–1598` explicitly replaces null/undefined/empty messages with `(無訊息內容)`; lines 1634–1650 choose initial width and only enlarge an already populated window if the subsequent message requires it. A shorter appended message does not shrink the existing window. Messages remain accumulated/deduplicated until confirmation.

The generated function dereferences `msg.length` without the source guard and recalculates width unconditionally for every appended message. Using the artifact's existing minimal DOM harness, with all artifact writes suppressed and only generated prototype code executed, reproduced:

- `showModal('123456789012345678901234567890')` then `showModal('短')`: width changes **450px → 180px**, while both messages remain accumulated.
- `showModal('')`: visible content is `""`, not `(無訊息內容)`.
- `showModal(null)`: throws `TypeError: Cannot read properties of null (reading 'length')`.

The support contract does state the empty placeholder, so the empty case also disagrees with the generated textual contract. These are known source interactions, not missing external dimensions. Correction: preserve the empty-value normalization and non-shrinking accumulated-window rule, including the source's width calculation on transformed message content; document those rules and add meaningful boundary scenarios. Existing mock AC-10 covers a normal message and one-shot keys only, which explains why it passed.

### AF-SR-04 — Available CSS cascade for button padding is dropped (low)

Affected positions: `artifacts/design/AF-AFY10400/prototypes/SCR-01.html:4` and CMP-07 support at `artifacts/design/AF-AFY10400-support/contract.md:55`.

Source `inputs/frontend/sourceCode/CM/css/cm.css:108–124` sets the base `.button` padding to zero, but the later **`:root .button, :root .button1, :root .buttonRed { padding: 0px 10px; }`** at lines 162–164 overrides it in the page's stated modern-browser context. Source root lines 191,217,227 explicitly identify Chrome and use `.button` for add/export; dynamically created delete buttons likewise use that class (line 41).

The generated CSS keeps `.button { padding:0; }` and omits the available later override. This changes add/delete/export button width and horizontal text spacing independently of missing images or font assets. Correction: carry the effective relevant cascade into the prototype/support contract, rather than only the first class declaration. No browser-equivalence claim is needed to establish that the generated declarations differ from supplied source.

### AF-SR-05 — Deferred TODO identifiers remain unlinked at affected contract locations (low)

Affected examples:

- `artifacts/design/AF-AFY10400/specification.md:33,36`: DATA-06 uses bare TODO-03; DATA-09 uses bare TODO-01/04.
- Specification lines 76,92,105: ST-05, TR-08 and MSG-03 acknowledge target-result/markup gaps with bare TODO-03 rather than local tracking links.
- `artifacts/integration/AF-AFY10400/api-spec.md:30–31,37–40`: affected array/CRLF/envelope/message/result rows use bare TODO-03/05 or describe the gap without a local tracking link.

The missing target/host capabilities are correctly indexed and substantial FLOW/UI/BOUND positions do have links. However, these directly affected rows do not meet the explicit per-position linked-gap requirement of `skill/references/dependencies.md:26` and skill criteria, even though a reader can search the central index. Tracking TODOs already link to follow-up tasks and DEC-01.

Correction: turn each affected local marker into a tracking link (and add a marker where the affected row has none), retaining the existing follow-up/decision path. No new simulated authorization is needed.

### AF-SR-06 — Root behavior specification includes internal protocol/helper symbols (low)

Affected positions: `artifacts/design/AF-AFY10400/specification.md:126,130,142,146`.

Examples are `response/JSON`, `HTTP非成功`, `failureAction`, `callback`, `complete`, `helper`, and `WIUtil` as parts of normative FLOW prose. These are source exchange/helper details rather than user-observable concepts. The independent API projection, support/evidence mapping and tracking already provide places for the precise technology details.

Correction: express root FLOW conditions as receipt of a readable service response, transport failure, page result handling, exchange completion, parent message-region clearing and the externally supplied message presenter. Preserve exact technical mapping in the API/evidence/support records. The behavior and source evidence do not need to change. Skill evidence technical-neutrality rules and acceptance's separation criterion apply.

## Confirmed strengths and boundaries

| Concern | Independent assessment |
| --- | --- |
| One root; bounded support | The only root is AF/AFY10400.jsp. AF-AFY10400-support is explicitly a versioned set of seven necessary component fragments, not a second complete JSP scope. Its consumers and source evidence are identified; unused PageUI/Validator/calendar/date features are not invented as product capabilities. Plan lines 36–48; support lines 3–55; tracking lines 7–11,46,68. |
| Plan-before-analysis record | Initial source/version/boundary and pending dependency tasks are retained, then CHANGE-01 dependency/decision additions and task states. Plan lines 5–28,30–59; tracking lines 17–23,130. Final files supply a sequence record; they do not independently prove historical write/read order. |
| Task dependencies/impact | Initial TASK-01–05 and follow-up TASK-06–09 identify prerequisites, affected outputs/IDs, closure/verification conditions and revalidation. Simulated DEC-01 is explicitly sourced to task.txt and does not claim formal scope expansion. Available necessary dependencies are converted to support-v1; missing providers/assets are deferred with TODOs. |
| Root facts and operation order | Initial zero rows and L/AT, both distinct titles, three instructions, max10 ID/3×30 policy textarea, monotonic row IDs, delete without confirmation and position-based recoloring are retained. Export's current-row empty check precedes its comparisons with later IDs; zero rows and whitespace are not silently rejected. Form.serialize, not the temporary param object, is recognized. All current rows are filled before success download handoff; business failure does not download. Root lines 22–124,188–230; specification FLOW-01–05/BR-01–03. |
| Policies/time/gestures | Policies retain whole body/window event scope, including review region; no Ctrl+Q behavior is invented. Copy normalization, comparison before truncation, original length, percent replacements and independently expiring 60-second timers are preserved. Message-window first-keypress removal and down/move/up black-frame intermediate state are retained. Watermark misspelled event/fallback differences are documented instead of silently repaired. |
| API authority/projection | Correct specified Markdown baseline dated 2026-08-12, snapshot version, exact export/download operation IDs and paths, nonrequired DTO fields, uppercase parallel arrays, success envelope, HTTP200/code500/data:null errors and binary download distinctions. Only stub Content-Disposition is asserted. Prompt/rtype/promp is accurately recorded as existing but not consumed by this root; no date or query UI is added. Source OPENAPI lines 3–23,39–67,500–567,741–751; API projection lines 3–75. |
| Responsibility handoff | Four handoffs preserve trusted functional/user context, copy logging, failed-result mapping and JSON-helper/binary-download incompatibility. Business query/validity/Excel generation are not reproduced in the prototype. Legacy method specifications support old semantics without replacing target wire authority. Backend handoff lines 5–38. |
| Verification scope | Static parsing, Node syntax and minimum-DOM/fake-time checks are separated from browser, legacy and actual integration. The output remains partial with open TODOs and no pixel-equivalence, real-download, real-write or live-backend pass claim. The specific date metadata claim needs AF-SR-01 correction; the narrow checks otherwise reproduce. |

## Independent reproduction and audit limits

- All **34** manifest snapshot hashes match; the inventory's **16** source hashes also match. Source bytes were not changed.
- Root CP950/Big5-family handling was checked directly from original bytes, with original CRLF/246-line basis retained. Other recorded source line counts match except date.js; its strict decoding issue is AF-SR-01.
- Re-executed the artifact `static_check.py` in memory with `Path.write_text` patched to suppress writes: **94** Markdown links/anchors, **26** HTML IDs, **16** source hashes, zero reported failures and no external-resource refs. Confirmed recorded prototype-script.js exactly equals current HTML script extraction. Encoding metadata is outside this script's assertions.
- `node --check artifacts/renovation/AF-AFY10400/checks/prototype-script.js`: exit 0.
- Re-executed the generated prototype mock harness with `fs.writeFileSync` suppressed: all **nine** recorded assertion groups passed. Then used the same harness for AF-SR-03's three additional message-window probes. No legacy JavaScript was executed.
- No browser rendering, real event/default behavior, real timer observation, historical tool availability, backend calls or original external filesystem provenance were independently verified. No evaluation suites/reports were read.

Recorded passes therefore remain valid for their stated static/mock scope, but are not proof of source coverage for unasserted branches or of the wrong date.js metadata. The historical plan/support creation order and earlier browser-tool search are documentary claims only in this audit.

## Expected external gaps, separate from defects

TODO-01: actual function-policy/watermark flags, trusted login/time/environment providers, tag/config/instrumentation implementations and copy-audit adoption. TODO-02: bottom-frame/rollback host, WIUtil internals and actual system/forced route. TODO-03: target error data lacks old per-ID failure results; markup versus text and synchronous encrypted-download-info versus direct binary remain real compatibility gaps. TODO-04: border/title/button/cover/loading image assets, unusual-glyph fonts and watermark tool are not supplied. TODO-05: complete enum/null/zero-row/array/CRLF acceptance rules, formal authentication/gateway/environment and nonstub download headers/guarantees remain unconfirmed. TODO-06: actual browser/legacy visuals, keyboard/drag/timer/network observation and runtime branch validation remain unexecuted.

Those expected missing materials do not justify inventing answers or calling this complete. They also do not explain away the available-source defects listed above. The existing partial-delivery label should remain after the localized corrections.
