# Independent semantic review — continuation/coupled

Reviewed 2026-10-12. Scope: this case's task, manifest, skill and references/templates, provided frontend/backend/component-contract snapshots, immutable prior delivery, current artifacts, and artifact-owned checks. No evaluation suites, existing reports, other cases, parent conclusions, network, legacy runtime, or backend calls were used. Only this report was written.

Verdict: the delivery is a substantially faithful **partial** continuation, with two medium contract/traceability defects and one low presentation defect. No high-severity generated defect was found. External contract/environment gaps remain open and are not counted as generated defects.

## Generated defects

### C-01 — Medium: the claimed complete impact expansion omits style-affected UI definitions

- Source: `inputs/frontend/styles/base.css:1` applies font, maximum width, margin and color to the whole page; `:4` gives the action bar its spacing. `inputs/frontend/Case.jsp:48–58` places UI-01–08 under that page styling and UI-04 in that action bar. The reusable button contract, `inputs/specs/action-bar.md:3–11`, covers button/event responsibilities, not these styles.
- Current delivery: `artifacts/design/fixture-case/specification.md:52–59` includes TODO-06 only at UI-05. In particular UI-04's definition at `:55` and CMP-01 at `:63` do not reveal that their page-use spacing depends on the deferred style contract. UI-01/02/03/06/07/08 likewise lack the style TODO at their definitions. `artifacts/renovation/fixture-case/checks/gap-map.json:106–125` repeats this reduced list, so the check cannot catch omitted impact IDs. `tracking.md:154,254,260,268` describes the list/90 position checks as the complete current expansion and completed gap-position work.
- Requirement: `skill/references/dependencies.md:26–28` requires every affected FLOW/CMP/UI/BOUND/DATA/ST definition to carry a linked gap and requires expansion of all affected IDs. `skill/references/acceptance.md:29` explicitly says a central index cannot substitute for affected positions.
- Impact: the source styling and deferred dependency are preserved globally, but a consumer following the individual button/UI definition can miss its dependency and revalidation obligation. The reproduced 90-pair pass proves the selected map entries, not that the map is exhaustive.
- Correction: distinguish the style and bridge impacts within TODO-06; expand the style impacts to all applicable UI/page-use component definitions, add direct TODO-06/TASK-07 links there, and update the impact map/table and completeness wording. Reusing CMP-SEARCH-ACTION remains valid; its existing behavioral contract need not be rewritten.
- Origin: inherited impact undercount remains unresolved; 0.2 newly asserts comprehensive position verification over the undercounted map.

### C-02 — Medium: AC-06 does not define the request identities needed to test response inversion

- Source: `inputs/frontend/Case.jsp:19–36` creates independent callbacks and applies each arrival without a latest-request guard. `skill/references/acceptance.md:18,31` requires concrete case preconditions/events and observation of temporal ordering.
- Current delivery: `artifacts/design/fixture-case/specification.md:147` says two queries are pending, then an empty response arrives, then a success response arrives. It does not identify which response belongs to the first-started versus second-started request, even though its expectation claims that responses are not discarded according to latest start order. `artifacts/integration/fixture-case/api-spec.md:82` cites AC-06 for response interleaving.
- Impact: a reader can execute the two requests and their responses in start order, obtain the stated final rows/message, and never test whether an older request remains usable after a newer response. That does not establish the particular ordering obligation the case claims to cover.
- Correction: explicitly define requests A then B; deliver B's empty result first, observe empty rows/message, then A's successful two-row result, observe retained message and A's rows. Include the intermediate observations and distinguish start order from arrival order.
- Execution qualification: `artifacts/renovation/fixture-case/checks/prototype.js:37–41` already executes second-started then first-started callbacks and passed on rerun. This is a case-definition deficiency, not a failure of the prototype's interleaving behavior or a fabricated script pass. Origin: inherited AC-06 definition remains underspecified in the continuation.

### C-03 — Low: integration entries fall outside the Markdown impact table

- Current delivery: the blank line at `artifacts/renovation/fixture-case/tracking.md:243` terminates the table, then `:244–248` supplies five HANDOFF/API pipe rows without a new table header/separator. Under GitHub-flavored Markdown these form plain text rather than additional table rows.
- Requirement/impact: the actual links still exist and resolve, but the claimed impact-position table does not render its integration portion as a table, making the verified relationship harder to inspect. See `skill/SKILL.md:79` and `references/acceptance.md:19` for understandable, maintainable linked records.
- Correction: keep these rows contiguous with the preceding table or introduce a separate integration table with its own header and delimiter row. Origin: introduced in 0.2.

## Confirmed strengths and external gaps

- The root entry and chosen fixture-v1 backend baseline remain fixed. The current E-01–15 evidence-table rows are byte-for-byte identical to the prior delivery; prior IDs and historical results are retained, and new results are separated from history. The retained P0 chronology is inherited documentation, not independently established by this audit.
- The source's clear-status-before-send, retain-old-rows-while-waiting, clear-rows-before-response-branch, collection order, exact NONE/BLOCK/empty-quantity messages, success-message retention, and exact-empty-only quantity guard are preserved in text and prototype. The script includes no backend quantity calculation, Ledger side effect, or network request.
- API-01 accurately retains the provided operation/method/path, JSON media type, optional queryText with length/empty/null rules, service-owned unit identity, required known envelope/row fields and three known outcomes. Independent API-AC-01–08 replace the prior overbroad AC-02 coverage claim and avoid claiming a service execution pass. The reusable fixture-component-v1 source/hash and local use match the provided action-bar contract.
- HANDOFF-01–03 retain missing trusted initialization, quantity parsing/calculation/write responsibilities and ordering, and the third-column output gap without inventing endpoints or target capabilities. DEC-01/02 remain explicitly sandbox simulations. Follow-up tasks include dependencies, effects and completion/revalidation conditions; open TODOs are not closed by document production.
- **External contract gaps:** target reviewer initialization, rankHint, quantity operation/business/write guarantees, Ledger internals, authentication, non-200/other-result handling and missing reusable style/bridge contracts are not supplied by the inputs. The audit does not require inventing them or expanding scope. These are correctly retained as partial-delivery limitations.
- **Verification gaps:** browser rendering, actual native-dialog presentation, keyboard/focus, console/network observation, legacy visual comparison and real API/business execution remain unverified. The delivery states this honestly, does not infer deployment from an absent call environment, and corrects the inherited overly broad claim that task.txt separately prohibited all local legacy execution. This audit did not attempt those environments and does not independently establish the recorded browser-availability probe.

## Reproduced checks

Run from the case directory without changing the delivery:

1. `python3 artifacts/renovation/fixture-case/checks/static.py` — exit 0. Manifest hashes, UTF-8/LF, local links/fragments, prototype structure/constants, retained API identifiers, selected impact positions, eight API case presence checks, prior ID retention, and integration gap links passed.
2. `node artifacts/renovation/fixture-case/checks/prototype.js` — exit 0. Generated prototype script executed against its explicitly minimal fake DOM; trim/status/old-row timing, synthetic rows, empty/denied branches, reversed responses/message retention, alert invocation/blocking, nonempty review boundary, other-result behavior and review reset/toggle passed.
3. Independent read-only comparison — prior E-01–15 evidence rows preserved verbatim; map contains exactly 90 design/integration pairs; UI-01/02/03/04/06/07/08 each lacks both its TODO-06 row link and a TODO-06 map entry; AC-06 lacks first/second request identity; integration pipe rows are separated from the table by a blank line.

The first two reruns agree with the saved stdout in `artifacts/renovation/fixture-case/checks/results.txt`. The static checks validate their declared selections, not semantic exhaustiveness; the fake DOM result is not browser, legacy or backend validation. No outputs, skill, inputs or manifest were edited.
