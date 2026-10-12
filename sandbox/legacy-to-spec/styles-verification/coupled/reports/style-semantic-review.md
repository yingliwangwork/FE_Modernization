# Coupled repair re-audit

**Disposition:** The bounded repair resolves F-01 and FORMAT-01. No remaining defect was found in the repaired source ranges, typography shape, DESIGN/DTCG path mappings, customization handling, or API authority checked here. External contract gaps remain open, and delivery remains partial.

This is an independent review-guided maintenance audit of the current case-local skill/rules, task/manifest, raw frontend/backend/customization inputs, final artifacts, prior style/format findings, and selected prior artifacts. No evaluator or browser suites, live browser reports, root check reports, or underlying prior-browser report were read. Only this report was written; no artifact or input changed. No network, JSP/backend execution, or browser rerun occurred.

## Repair verification

| Finding | Direct current evidence | Final disposition |
| --- | --- | --- |
| F-01: source ranges exceed raw snapshots | Raw `inputs/frontend/legacy-bridge.js` has 8 physical lines and `inputs/specs/action-bar.md` has 11, counted from bytes with splitlines. `artifacts/renovation/fixture-case/plan.md:49` now says 8 lines; `artifacts/design/fixture-case/dependency-contracts.md:11` and `artifacts/renovation/fixture-case/tracking.md:31,52` use 1–8; tracking.md:36 uses 1–11. | Resolved at every previously identified location. No source bytes or line-count convention was changed. |
| FORMAT-01: typography is a CSS string rather than a named object | `artifacts/design/fixture-case/components/CMP-PAGE/DESIGN.md:6–8` now contains `typography.page.fontFamily: "sans-serif"`. Independent YAML inspection confirms the entire typography map is exactly `{"page":{"fontFamily":"sans-serif"}}`, with no invented font size, line height, or weight. | Resolved under the current skill profile. |
| Previously withdrawn F-02 | Current tracking retains explicit DATA-06/DATA-07 entries and definition links. The supplied prior review already withdrew this intermediate-read observation. | No final-byte defect to repair; not reopened. |

I independently ran the current read-only `skill/scripts/check_design_metadata.py` on the three final DESIGN files: PASS, with zero findings. Running the same helper on the preserved prior CMP-PAGE file returned FAIL for `typography.font-family` being a string instead of an object, reproducing the original shape defect against the retained bytes. The helper never modifies its inputs.

## Values and path mapping

- CMP-PAGE STYLE-01 at DESIGN.md:49 explicitly identifies the DESIGN path `typography.page.fontFamily`; its value resolves to source-confirmed `sans-serif` and the CSS still declares that exact family. The row also states that this font value is not exported to DTCG.
- All eight paths explicitly labeled DTCG resolve in `styles/tokens.json`: `page.maxWidth`, `page.margin`, `page.textColor`, `table.marginBlock`, `table.borderWidth`, `table.borderColor`, `table.cellPadding`, and `action.marginTop`. All values match the raw stylesheet: 720px, 24px, #222, 16px vertical margin, 1px border, #555, 6px padding, and 8px top margin. The colors retain sRGB components 34/255 or 85/255 and alpha 1.
- DESIGN frontmatter is parsed as YAML; DTCG remains separate typed JSON. The mapping distinguishes each namespace instead of suggesting that DTCG `page.*` paths exist in DESIGN frontmatter. Percentage width, compound margin/border, and remaining CSS keywords remain exact in the CSS/body rules. The added component footnotes explain the eight-value selected export and acknowledge DTCG fontFamily support rather than treating every unexported keyword as inherently unrepresentable.
- Concatenating the three final component CSS files in prototype link order exactly reproduces all four raw stylesheet rules and eleven declarations. STYLE-01 through STYLE-11 still cover page 01–04, table 05–10, and action 11; no source-confirmed style value or state applicability was lost. All three component DESIGN/CSS pairs remain linked from the main specification and the HTML links the delivered local CSS files.

## Customization and API authority

The current template-selection record selects the project-root DESIGN template and explicit API override, with builtin fallback for the other roles. All nine selected template hashes, the config hash, and supplementary reference hash independently match the current files; every selected template path is inside this continuation case. The preserved prior selection record is separately available under inputs/prior-artifacts. Tracking.md:154 identifies the new record as maintenance selection, not a claim that every existing artifact was regenerated.

Each DESIGN file retains the custom Adoption Scope section. API Consumer Impact and the supplementary 相依消費端 section remain present, and the API document is byte-identical to its preserved predecessor. Direct comparison with the current raw backend baseline confirms `searchItems`, `POST /v2/items/search`, optional string `queryText` with length 12, omitted/empty/null distinctions, server-provided unit context, required `outcome`/`rows`, required `rowId`/`label`, and the three outcome mappings. The formatting rules supply no new wire facts. rankHint, reviewer initialization, quantity processing/storage, authentication, and unspecified error behavior remain identified gaps; no replacement operation or invented schema closes them. The backend handoff and main specification are also byte-identical to their preserved predecessors.

## Runtime inheritance and check scope

I compared final bytes against inputs/prior-artifacts for all six relevant delivered resources: three component CSS files, SCR-01.html, prototype.js, and tokens.json. Every comparison is identical. Thus the repair did not change those runtime resources; the changed DESIGN metadata is separately evaluated by current parsing and source/value checks. Tracking.md:148–159 explicitly separates historical generation checks from maintenance and labels V-07 as inherited prior observation with no browser rerun. This audit confirms the byte-identity condition, not the correctness or completeness of the underlying browser measurements, which were not read or repeated.

The local metadata helper checks nonempty name, selected group mapping shapes, object-valued typography/components, color value string types, allowed typography field names, and fontFamily string type. It does not check full official schema compliance, CSS color validity, version/omitted semantics, aliases, all value types, sections, source fidelity, DTCG, or browser rendering. The independent value/path comparisons above provide separate evidence for the particular repaired values; helper PASS alone would not establish them.

I independently checked 38 skill/raw-input manifest hashes and 17 non-check artifact hashes: no mismatches. Every examined Markdown local target file exists. These are bounded integrity/structure checks; existence and matching hashes do not establish semantic completeness or actual browser loading, and this target-file check does not independently prove every Markdown fragment anchor. The plan at lines 3–13 records TASK-07/08 before repair and tracking.md:148 records that sequence; frozen final snapshots alone do not establish the timing of edits.

## Remaining input/runtime limits

TODO-01–04 remain open for missing initialization, rankHint, quantity/module/session responsibilities, authentication, and unspecified failure contracts. The current backend baseline remains a sandbox contract without a callable environment, while deployment status is separately unconfirmed. No live API acceptance, JSP execution, business charging/storage, or source-system pixel equivalence was tested. The original system execution screen is unavailable. These are retained delivery limits rather than unresolved versions of F-01 or FORMAT-01.
