# Independent semantic review — AFY10400 baseline

Reviewed 2026-10-12 after the parent confirmed generation had completed. Criteria were established first from task.txt, manifest.json, the frozen skill/SKILL.md, and supplied raw inputs. Root JSP and relevant shared sources were decoded using their supplied bytes, including strict Big5 decoding of the root. This review did not inspect tests/, parent skill edits, other repositories, the parent's browser inspection, or its scenario suites. No browser session or endpoint was opened. Only this report was written.

## Result

Substantial, honestly qualified **partial** delivery. No critical or high issue was established. One medium preservation gap and three low refinements remain. The API wire contract, coupled responsibility split, normal user guards, zero-row initial state, and known target/legacy incompatibilities are handled well. Missing service/environment evidence is kept open instead of being replaced with artificial success.

## Findings

### A-01 — Medium: a supplied conditional asynchronous feedback branch is incompletely preserved

- Source: `inputs/frontend/sourceCode/CM/js/ajax/CSRUtil.js:626–680`. The prototype responder chooses custom MsgWin for a listed group of location-derived systems; other systems use native feedback. In the latter branch, errors optionally prefix a long message ID (`msgid.length>17`), then alert `訊息說明：\n` plus the response text. Nonerror, nonempty messages also alert when there is no bottom message board and success display is enabled. These are defined conditions, message construction, and observable outcomes in a supplied dependency.
- Artifacts: `artifacts/design/AF-AFY10400/specification.md:85–91` describes shared feedback and adds CMP-05/custom MsgWin; `:132–143` preserves entrance message templates; `:149–158` covers entrance/clearing/custom confirmation. It does not separately specify the native asynchronous error and conditional success branch, or the asynchronous fullwidth-colon wording. Tracking E-08/E-17 and source coverage broadly index the dependency, but do not restore these particular alternatives.
- Effect: a consumer can retain the entrance message format and custom window while losing a source-defined alert condition or its exact text. The new envelope and deployment selection remain unresolved, but that does not make these legacy branch definitions unknowable.
- Correction: retain the conditional legacy native-alert branch, optional message-ID prefix, exact asynchronous message construction, and nonerror/no-board/success-display conditions, with source evidence. Keep actual deployment selection and target `code/msg/data` adaptation as TODOs; do not assume that this page always selects custom or native feedback. Add acceptance examples for the alternatives without claiming they ran in a browser.

### A-02 — Low: section-title spacing is changed without a recorded source limitation

- Source: `inputs/frontend/sourceCode/AF/AFY10400.jsp:175–184` renders the section title in a `p` inside a tbBox2 table cell. The supplied relevant CSS does not reset paragraph margins.
- Artifact: `artifacts/design/AF-AFY10400/prototypes/SCR-01.html:83,87` replaces that paragraph with a div and `.section-title{margin:0}`. The source-level paragraph spacing is discarded. The source's border-image/icon absence is disclosed, while this particular spacing change is not.
- Effect: expected browser paragraph spacing can make the title band shorter and move the input area upward. This is a source-structure inference, **not** an observed pixel difference or legacy screenshot claim.
- Correction: preserve the evidenced paragraph/title spacing or explicitly record the layout approximation. An actual legacy reference is still needed for pixel equivalence.

### A-03 — Low: zero-row state description can be read as resetting retained selections

- Source: root JSP:61–65 deletes and recolors only; it does not reset either select. Thus changing selections to R/CB, adding a row, then deleting the last row leaves zero rows and R/CB.
- Artifact: specification:97 defines ST-01 by zero rows but includes `初值 L／AT`; specification:112 explicitly returns deletion of the last row to ST-01 while retaining selections. Prototype:110,113 does correctly retain them.
- Effect: the implementation is correct, but a state-contract reader could confuse entry defaults with a zero-row invariant.
- Correction: say ST-01 permits current retained selections, and apply L/AT defaults only to the initial-entry transition. A delete-last-row case with nondefault selections would make this distinction explicit.

### A-04 — Low: two interaction-check labels imply evidence beyond their assertions

- Artifact: `artifacts/renovation/AF-AFY10400/checks/check_interactions.js:15–16` builds a zero-row table and assigns L/AT itself; `:22` then tests these harness values under the title `Initial zero rows; defaults preserved`. The HTML's initial selected options are not what those assertions read. At `:28`, `writes results before download-boundary state` checks final cells/state, not an ordered event trace.
- Effect: the ten reported checks really pass, but these two labels overdescribe their direct proof. There is no fabricated browser run: the report correctly identifies a minimal DOM substitute and excludes native/browser behavior. Source and prototype order are independently consistent.
- Correction: narrow those labels or inspect initial HTML for defaults and record cell updates/state changes for ordering. Do not treat the harness setup or final-state assertions as execution proof of those finer properties.

## Source-to-artifact assessment

| Area | Evidence and result |
| --- | --- |
| Entry and evidence scope | Exactly `inputs/frontend/sourceCode/AF/AFY10400.jsp` is renovated; shared header/messages/helpers support that scope. Tracking:9–39 locks root/baseline versions, encoding, boundaries, missing resources and date-helper decoding. Methods and other OPENAPI operations remain background or explicitly excluded. |
| Initial UI and interaction | Root:128–230 supplies both distinct titles, three instructions, L/R and AT/BG/CB ordering/defaults, initially zero rows, four columns, add control beside ID heading, and bottom export. Specification:33/64–79 and prototype:85–95 retain these details. Added rows preserve delete, maxlength 10 text field, three-line textarea and blank results; the source's alternating colors and deletion recoloring are retained. No mandatory initial row, minimum-one-row guard, confirm-delete, automatic focus or new search/date field is invented. |
| Guard and priority | Root:75–94 tests exact empty strings, then the current ID against subsequent IDs before moving on. Specification BR-01/02 and prototype:118–127 preserve the original alerts, whitespace handling, duplicate-before-later-empty priority, and zero-row boundary. Frontend maxlength is not promoted to backend validation or exact-ten-character client validation. |
| Serialization | Root:68–97 creates local `table1_I_ID/table1_POLICY_NOs` arrays but submits `Form.serialize('frm')`; they are not transmitted keys. Supplied prototype.js:6475–6519 preserves repeated-name order and normalizes LF to CRLF. API:49–54 maps actual I_ID/POLICY_NO names to parallel JSON arrays even for a single row, retains multiline text/CRLF semantics, and leaves zero-row omission/null/empty semantics unconfirmed. |
| Results and automatic download | Root:98–113 updates the fourth cell by current ID in both callbacks; only success then calls download with the returned fileName and `false`. Specification FLOW-05/06, API:61–75, and prototype:129–135 preserve result-first/download-next order and rejected-result/no-download behavior. They do not impose all-rows-success as a download gate. Review fixtures are disclosed as synthetic legacy shape rather than target API errors. |
| Target API exactness | Supplied OPENAPI.md:25–67/500–567 is the selected exchange baseline. API projection retains afy10400DoExport/DoDownload, POST paths, JSON object requirement, insrType/prodType/I_ID/POLICY_NO, code/msg/data envelope, HTTP 200 with code 500/data null for handled errors, success payload names, returned fileName source, download request media, binary success, stub-only Content-Disposition, and partial-binary uncertainty. Prompt is explicitly unconsumed; the exact wire name `rtype` and `/promp` alias are not replaced by legacy `isRType` or new UI controls. |
| Incompatibilities and handoff | Error `data=null` cannot satisfy the old failure callback's rtnMap expectation; old download JSON/encrypted parameters cannot consume the target's binary response. These are explicit TODO-01/02 and HANDOFF-02 rather than invented payloads/endpoints. Header function configuration, identity/time, protection/watermark flags and copy audit are split between frontend effects and trusted backend/environment obligations (HANDOFF-01); entry message/rollback supply is HANDOFF-03. Protection is conditional, not hardcoded as enabled or disabled. |
| Conditional shared behaviors | Header:70–99/128–181 supports function settings, restrictions and normalized/deduplicated/truncated copy audit; msgDisplayer:137–185 supports rollback early return, entrance alerts, and button clearing. Final E-17 correctly recognizes that MsgWin implementation is supplied and its deployment selection is unknown. Custom confirmation focus, first-keypress-only Enter/Esc/space handling and drag are retained in CMP-05/FLOW-10. A-01 identifies the remaining native-feedback gap. |
| Traceability and execution separation | All artifact Markdown links and anchors resolve independently. Tracking maps root events, callbacks, hidden/external state, helper logic, responsibility classes and selected API into E/LOGIC/FLOW/UI/AC/TODO records. No unresolved scaffold remained. Work/verification remains in tracking rather than being presented as user requirements. |
| Truthful limits | Final tracking:171–183 explicitly reports ten DOM-substitute checks and syntax/static checks, excludes real browser/native input/layout, and marks original JSP/backend/binary verification unexecuted. No service capability, persistence, protected deployment setting, formal header or pixel equivalence is inferred from fixture results. A-04 is an assertion-strength caveat, not a false-run accusation. |

## Independent checks and limits

- All 32 manifest entries match their SHA-256 values; artifact Markdown file links and anchors resolve.
- Both prototypes' current inline JavaScript compiled with Node `new Function`.
- Independently replayed AFY's generated interaction checks with `fs.writeFileSync` suppressed: **10 passed, 0 failed**. The extracted checked script matched current HTML byte-for-byte. No artifact was changed during this replay.
- No browser, native dialog/keyboard/input event, original JSP runtime, real function/identity setting, network monitor, backend request, binary transfer, audit write or persistence was exercised. Parent browser/scenario observations are intentionally excluded.

The unresolved target adaptation, conditional deployment behavior, dependency and runtime limitations support the generator's partial-delivery label. Resolving A-01 would improve preservation of already supplied source facts without pretending the missing environment or backend decisions are known.
