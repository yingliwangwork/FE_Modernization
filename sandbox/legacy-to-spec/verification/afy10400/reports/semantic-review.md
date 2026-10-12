# Independent re-audit: verification / AFY10400

Reviewed 2026-10-12. Read only the permitted current case raw frontend/backend inputs, skill, manifest, task, artifacts and `inputs/prior-review.md`. Historical artifact bodies, evaluator/browser suites, evaluator reports, other cases and parent findings were not inspected. No network, legacy or backend execution. All check writes were suppressed; only this report was added.

**Verdict: the six originally reported defects have received supported targeted repairs; one additional material prototype lifecycle defect remains.** The event-task repair is source-consistent, and the delivery honestly remains partial. Passing static/mock checks are not treated as source parity or full acceptance.

## Remaining generated defect

### AF-VSR-01 — Old message-window key handlers remove the new handler rather than themselves (medium)

Affected positions:

- `artifacts/design/AF-AFY10400/prototypes/SCR-01.html:34,101–102,126`: `keyHandler` is a mutable outer binding; each registered function removes the current value of that binding. Mouse confirmation does not remove the prior registration, and reopening overwrites the binding.
- `artifacts/design/AF-AFY10400-support/contract.md:45`, `artifacts/design/AF-AFY10400/specification.md:94,148,165`: the preserved contract says the first keypress consumes its listener, a nonclosing first key leaves the window open, and later Esc has no effect.
- `artifacts/renovation/AF-AFY10400/checks/prototype_mock_check.cjs:36,41–43`: the current checks test one-shot keys and mouse confirmation separately, but do not combine a mouse-closed previous window with the next window's letter/Esc sequence.

Source evidence: `inputs/frontend/sourceCode/CM/js/ajax/CSRUtil.js:1604–1632` creates a **local** `keyPressHandler` per initial display and removes that same function at line 1613. Source mouse confirmation (lines 1451–1473) can leave its unconsumed registration until the next keypress. When a new window opens, the old and new listeners each remove themselves on that keypress. Source then has no listener left to close the still-open window on a later Esc. It does not use one reassigned outer function reference.

Reproduced using only the generated prototype and its existing minimum-DOM harness, with `fs.writeFileSync` suppressed:

1. `showModal('first')`; mouse-click `message-ok` without a keypress.
2. `showModal('second')`: there are two registered keypress listeners.
3. Dispatch first keypress `a`: the window stays open, but **one stale listener remains**.
4. Dispatch subsequent `Escape`: **the second window closes**, contrary to the source and CMP-04/AC-10 contract.

The cause is independently visible in the current JavaScript, not inferred from an evaluator or browser report. The existing harness dispatches registered listener functions and exposes the removal error; no legacy script was executed. This is an ordinary two-dialog lifecycle, not an external host/API gap.

Correction: bind each registered handler's removal to that handler's own lexical identity, preserving the source's one-shot registration/consumption semantics. Add the combined mouse-confirm → reopen → letter → Esc case. Do not introduce continuous Esc handling or silently change the source's listener lifetime as a shortcut.

## Verification of the original six findings

| Prior finding | Targeted repair assessment | Current evidence |
| --- | --- | --- |
| AF-SR-01: date.js metadata | Corrected; input uncertainty remains honestly open | Inventory lines 333–371 records null analysis encoding, 1,089 byte-lines, 37,508 bytes, 1,088 CRLF pairs, UTF-8 failure offset 8 and CP950/Big5/Big5-HKSCS failure offset 40 in original line 3. Independently checked against raw bytes. Tracking V-01 withdraws the earlier encoding/line claim; current analysis does not guess damaged comment text. Root still strictly decodes as CP950, 246 original lines. |
| AF-SR-02: missing exception branch | Corrected for the reported source branch | CMP-03 line 37, MSG-07/TR-12, FLOW-04/09 and AC-15 distinguish diagnostic native alert from target business errors, enumerate actual exception properties and preserve diagnostic-return → subsequent completion. Prototype lines 62–78 provides labeled success/failure malformed-map scenarios. Compared with CSRUtil 684–692/2620–2637 and Prototype 1942–1964/1994–1996. |
| AF-SR-03: empty values/window shrink | Reported empty/width defects corrected; broader keyboard lifecycle still has AF-VSR-01 | Prototype lines 104–127 preserves transformed-string sizing, gray placeholder for empty/null/undefined, newline normalization/deduplication, conditional enlargement and reset after confirmation. CMP-04 line 43 and AC-16 state these rules. Current mock groups reproduce 450px retention, 600 cap, 180 reset, 495px placeholder and 240px normalized-newline case. This does not prove all message-window interactions. |
| AF-SR-04: CSS override | Corrected | Prototype line 4 includes the later `:root .button, :root .button1, :root .buttonRed` padding override, 0px/10px. Confirmation retains inline 0/15px. CMP-07 lines 59–61 explains both. Compared directly with cm.css 108–124/162–164 and CSRUtil confirmation style. |
| AF-SR-05: local TODO links | Corrected at the reported affected locations | Current DATA-06/DATA-09, ST-05/TR-08/MSG-03 and API array/CRLF/envelope/message/result rows have explicit links to tracking. Current static position check finds 82 linked gap positions across design/integration, with no bare TODO-ID failure; tracking retains follow-up TASK/DEC links and open statuses. This count is not evidence of unknown dependency internals. |
| AF-SR-06: FLOW protocol/helper leakage | Corrected at the four reported flows | FLOW-04/05/08/09 now describe readable responses, page result handling, exchange completion, message regions/presenters and file handoff. Exact wire/helper mappings remain in support/API/evidence; original diagnostic visible text is retained. No generic target-error behavior is invented. |

## Event-order repair and historical claims

Source `msgDisplayer.jsp:174–185` clears the parent message region on ordinary document button/submit clicks; source `CSRUtil.js:480–499` delivers an asynchronous response separately from the initiating click. Current prototype lines 150–152 keeps the global clear handler and schedules only the review `respond` delivery as `setTimeout(receive,0)`. This is a labeled review-tool task boundary, not a new product timeout, response priority policy or exemption.

Tracking CHANGE-03/V-11/V-12 (lines 184–195) records a historical **18/19** Chromium result, the failed bottom-receiver-after-callback observation, withdrawal of the earlier microtask claim and pending post-fix browser rerun. I did not open the linked report or browser suite and did not independently re-observe a browser. The current tracking therefore supports an honestly reported historical failure and repair scope, not a post-fix browser pass.

Independently replayed the current mock scenario and an **in-memory** mutation replacing `setTimeout(receive,0)` with the old `queueMicrotask(receive)`. The current version passes; the old microtask version is rejected with `'' == '訊息：已匯出'`, matching the stated controlled regression result. No mutated source was written. This supports the intended click/task ordering within the fixture and does not enlarge it into browser or source-runtime equivalence.

## Current delivery assessment

- One root/scope remains AF/AFY10400.jsp / AF-AFY10400. The support contract is explicitly seven necessary, versioned component fragments for this root, not another complete JSP renovation. Existing IDs/evidence remain; added MSG-07/TR-12/AC-15/16 are traceable.
- Plan retains initial source/boundary/decision/tasks and adds review tasks before repair records. Dependencies, affected contracts, completion checks and future revalidation remain visible. The explicit task.txt sandbox decision is retained; no formal project expansion or silent new deferral is claimed. Final documents record chronology but cannot independently prove historical creation order.
- Initial zero rows, L/AT defaults, distinct titles, instructions, max10 ID, multiline policy entries, monotonic row identity, delete/recolor order, exact empty/duplicate warnings and empty-before-later-duplicate ordering match raw source. No trim, forced exact10 front-end check or minimum-one-row rule is invented.
- Success/failure row-result responsibilities, fill-before-download and no download on business failure remain. Prototype fixtures are labeled; they do not query data, produce Excel, write logs or impersonate a real download. Unknown target error-result and helper/binary compatibility remain separate.
- Whole-page policy scope, independent copy timers, truncation after comparison, original length and encoding, one-shot key intent and drag black-frame intermediate state remain represented. AF-VSR-01 is a concrete failure of the key-intent implementation.
- API projection matches the selected OPENAPI snapshot: exact export/download paths and IDs, uppercase parallel arrays, nonrequired DTO fields, required ReturnMsg envelope, HTTP200/code500/data:null, both download request media, binary success and stub-only disposition. Prompt/rtype/promp is recorded as existing but unused; no extra UI is added. Backend handoffs remain source-based and do not fabricate endpoints or adoption.
- Partial status and TODO-01–06 remain appropriate. The current pass records precisely distinguish static assertions, mocked time/DOM, actual historical browser failure and unexecuted integration/legacy observations.

## Read-only check reproduction

Executed checks with all artifact writes suppressed:

1. Reproduced the artifact static checker with one explicit audit-boundary restriction: its manifest list excluded the **13 historical prior-artifact files**, whose bodies/hashes I did not read. The permitted **36** snapshot hashes (19 skill, 16 raw frontend/backend, prior-review) match. This is a scoped reproduction, not certification of the artifact's recorded 49-file historical-snapshot check.
2. Recomputed all **16** source inventory byte counts, physical lines, newline counts, strict-codec statuses/failure offsets and selected-analysis-codec validity against raw bytes. Date.js remains correctly unconfirmed; root CP950/Big5-family handling is preserved.
3. Current static scope reproduces **158** Markdown links/anchors, **28** HTML IDs, **82** linked gap positions, source-byte checks, button declaration and targeted FLOW-neutrality checks, with zero reported failures/external resource refs. Link existence is not permission to read linked evaluator reports; none were opened.
4. Confirmed current HTML script exactly equals recorded `prototype-script.js`; `node --check` exits 0.
5. Replayed all **15** recorded generated-prototype mock groups successfully; no legacy JavaScript was executed. The separate AF-VSR-01 combined-lifecycle probe fails source parity despite those passes.
6. Replayed the old-microtask mutation in memory and observed its expected rejection. No file was changed.

The reported checks are credible for their specific assertions. They do not cover AF-VSR-01, all dynamic message values, browser defaults/rendering, real 60-second timing, trusted hosts or real service behavior. No post-fix browser pass is certified by this report.

## Expected open gaps, not generated defects

Trusted policy/login/time/context and copy-audit adoption (TODO-01); bottom frame/WIUtil/actual system host and branch (TODO-02); target per-ID failure payload, markup/text and legacy-info/binary download compatibility (TODO-03); image/font/watermark assets and tool (TODO-04); complete values/null/zero-row/CRLF rules, formal authentication/environment and real download guarantees/headers (TODO-05); remaining browser/legacy/real-host observations and post-event-fix Chromium rerun (TODO-06). Date.js's unreconciled original comment bytes are an explicitly retained input limitation.

These gaps should remain open without new evidence. Correcting AF-VSR-01 would improve the available-source prototype behavior but would not make the renovation complete or justify closing the external/validation TODOs.

## Final resolution: key-handler repair verified (2026-10-12)

This addendum supersedes the open disposition of AF-VSR-01 above; the original finding and reproduction remain as history.

**AF-VSR-01 is resolved. The earlier six targeted repairs remain intact. No generated defect remains open among the findings independently audited in this report. The delivery remains partial because its external and runtime-validation gaps are still open.** This bounded follow-up does not certify unknown dependencies or whole-system/browser parity.

Current `artifacts/design/AF-AFY10400/prototypes/SCR-01.html:126` creates a show-local `const firstKeyHandler` and removes that same lexical function on the first keypress. This matches raw `inputs/frontend/sourceCode/CM/js/ajax/CSRUtil.js:1609–1632`, independently reread through strict CP950 decoding. Mouse confirmation still leaves an unconsumed registration until a keypress, preserving the source lifecycle instead of adding new cleanup semantics. The source-consistent next-task response injection remains in place.

Read-only reproduction, with all artifact writes suppressed:

- Current **16** generated-prototype mock groups pass, including the new combined mouse-confirm/reopen/letter/Esc/third-show-first-Esc regression at `checks/prototype_mock_check.cjs:50`.
- Independently repeated that combined sequence: after the first letter, registered keypress listener count is **0**; the second window stays open on later Esc; a fresh third window closes on its first Esc.
- Replaced only the handler closure in memory with the old outer mutable reference. The same regression rejects it with **`1 == 0`** at the listener-count assertion. No mutated source was written.
- Current static-check scope passes: **36** permitted snapshot hashes, **16** byte/codec records, **160** links/anchors, **28** HTML IDs and **82** linked gap positions, plus retained effective button padding and targeted neutral-FLOW checks. Historical prior-artifact hash reads remain excluded from this independent reproduction; the recorded 49-file result is not recertified here.
- Current prototype script exactly matches the HTML extraction; Node syntax check exits 0. The retained mock groups continue to cover the earlier exception, empty/null/undefined, accumulated-width, copy/timer and response-order repairs. Their specific passes do not imply exhaustive source parity.

The existing historical 18/19 Chromium observation remains a pre-event-fix record; this addendum does not inspect evaluator/browser reports or claim a post-fix browser pass. Actual browser verification of the reopened-window scenario, remaining host/image/font/watermark behavior, backend compatibility/adoption, real downloads/logging and legacy visual comparison remain outside this audit. TODO-01–06 and the honest partial-delivery status should remain open.
