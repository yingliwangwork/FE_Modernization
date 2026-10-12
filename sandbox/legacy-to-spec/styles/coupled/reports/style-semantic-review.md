# Coupled style/customization semantic review

Independent source audit of the case-local skill, needed customization/style/API/evidence/acceptance rules, manifest/task, supplied inputs, and generated contracts/prototype/styles/tracking. No evaluator reports, browser suites, other trials, or parent conclusions were read. No artifact or input was changed. Own checks are in [style-own-checks.json](style-own-checks.json).

**Result:** No substantive loss of source-confirmed styles, invented product design, or API-authority violation was found in this bounded static audit. One low-severity evidence-range defect remains. The initially reported F-02 does not occur in the final tracking file and is withdrawn. Browser loading, computed styles, native behavior, geometry, and pixel equivalence were not established by this audit.

## Findings

### F-01 — Low: evidence ranges exceed raw snapshots

`artifacts/renovation/fixture-case/plan.md:38` describes `legacy-bridge.js` as nine lines. `artifacts/design/fixture-case/dependency-contracts.md:11` and `artifacts/renovation/fixture-case/tracking.md:31,52` cite lines 1–9. The raw `inputs/frontend/legacy-bridge.js` has eight physical lines. `tracking.md:36` similarly cites `inputs/specs/action-bar.md` lines 1–12, while that snapshot has eleven lines.

The supplied `source-inventory.json` correctly reports 8 and 11 physical lines and explicitly states that a terminal newline adds no line. The cited code and contract are otherwise locatable, so this is a documentation precision issue rather than a changed behavior. Correct the references to 1–8 and 1–11 and the plan count to eight. Relevant requirement: `skill/guides/evidence.md` requires original source line numbers or stable symbols.

## Supported checks

- Template selection uses the explicit API override and project-root DESIGN template, with builtin fallback for the remaining roles. All nine selected template hashes, the profile hash, and the supplementary API-reference hash match the provided files. Custom `Adoption Scope`, `Consumer Impact`, and the supplementary `相依消費端` section are retained. No unexpanded artifact placeholders were found in the examined Markdown/HTML/CSS.
- The API projection at `artifacts/integration/fixture-case/api-spec.md:15–48` preserves `POST /v2/items/search`, operationId `searchItems`, optional string `queryText` with length 12, omission/empty/null distinctions, server-provided unit context, the required `outcome`/`rows` body, required `rowId`/`label`, and the three outcome mappings. The custom writing rules do not supply wire facts. Missing rankHint, initial reviewer data, quantity handling, authentication, and failure contracts remain explicit gaps. No target endpoint/schema was invented for the unimplemented responsibilities.
- All three source-styled components have DESIGN.md and delivered CSS. `SCR-01.html:5–7` links the three existing local CSS files. Concatenating CMP-PAGE, CMP-TABLE, and CMP-SEARCH-ACTION CSS in that order exactly reproduces `inputs/frontend/styles/base.css`: four rules and eleven declarations, including page layout/font/color, table layout/borders/cell presentation, and action spacing. The prototype contains no inline style element or attribute and no remote HTML resource/action reference.
- The eleven source declarations map to STYLE-01 through STYLE-11 without duplication: page 01–04, table 05–10, action 11. Source E-05 is tied to the exact stylesheet hash and lines 1–4. The DESIGN maps retain exact units, percentage width, compound margins/border, inherited/native-control limitations, and the all-known-state applicability. No new hover/focus palette, font scale, radius, breakpoint, loading presentation, or disabled state was found.
- All eight token values agree with their source-backed mappings. px dimensions use numeric value plus px unit; text #222 maps to sRGB components 34/255 and border #555 to 85/255 with alpha 1. Percentage width, compound values, and CSS keywords remain explicit in DESIGN/CSS with stated token limitations. This is a bounded value/shape check, not full DTCG or DESIGN alpha schema validation.
- Main specification and prototype source agree on product order/labels, maxLength 12, trim timing, clearing status on request start while retaining old rows, clearing rows on response, successful response order, exact empty/denied messages, preserving interleaved status text on success, unknown-readable-result behavior, and the exact empty-quantity alert. The prototype exposes pending-request selection in the review layer and stops nonempty quantity submission at the documented boundary; it does not implement backend charging/storage. Synthetic reviewer and rankHint data are marked as review substitutes and do not close their gaps.
- All examined Markdown local target files resolve once tracking and the artifact hash file are present. The 17 non-check artifacts listed in artifact-hashes.json match their current hashes. All 36 manifest snapshots and the 11 inventory records match actual file hashes; inventory physical-line counts also match raw bytes.

## Input and runtime limitations

The supplied backend baseline is a sandbox contract without a callable environment. Reviewer initialization, rankHint, quantity processing/storage, module/session internals, authentication and unspecified failure contracts remain incomplete inputs or target-contract gaps. The generated handoff and partial-delivery labels preserve these limits; this audit did not execute JSP, backend business logic, or an external service.

The original system execution screen is unavailable. This audit performed static source comparisons and bounded Python parsing/hash/value checks, with no browser session, computed-style measurement, native alert/event test, screenshot, or geometry assessment. Therefore the actual application of linked CSS and visual/native-interaction equivalence remain for separate runtime verification. Tracking V-04 explicitly records that the generator did not perform browser verification. No official DESIGN alpha or DTCG validator was used or claimed.

These limits are separate from F-01/F-02 and do not establish an implementation defect. The style/customization outputs support a partial static delivery, with the F-01 evidence-range correction above and browser verification still outstanding within this audit’s scope.

## Review correction history

F-02 was based on an earlier tracking-content read that showed bare `06`/`07` at then-lines 115–116. I incorrectly carried that observation into the final review without rereading that table after generator completion. The final `tracking.md:112–113` explicitly links `DATA-06` and `DATA-07`; final lines 115–116 instead link `ST-SUBMIT` and `FLOW-03`. F-02 is withdrawn from the final-trial findings. No artifact was edited during this correction.

The current final tracking SHA-256 is `9e7ed781f548c77dff9cbdff96e9d45ad6f447ed0ec484b1f78386ab7c443c19`, matching both the audit’s recorded bounded-check snapshot and artifact-hashes.json. The earlier content read had no separately captured hash, so it is retained only as review history rather than as evidence of a final-byte defect. F-01 and external format validity remain separate.
