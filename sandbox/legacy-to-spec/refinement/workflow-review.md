# Independent dependency/workflow audit

Audit date: 2026-10-12. Reviewed the maintained `skills/legacy-to-spec` package, repository README, sandbox preparation/checker, harness tests and test README. Did not read earlier sandbox reports, conclusions, or generated trial outputs. No network access; no skill edits.

The maintained skill expresses all requested workflow requirements. The audit found one reproducible harness defect affecting the authorized first-convert route and one internal documentation inconsistency. The latter is not evidence that current generated specifications contain tracking content.

## Findings

### W1 — P2: The structural checker rejects a properly separate dependency JSP scope

Locations: `scripts/skill-sandbox.py:187-188`, `:213-225`, `:231-239`; permitted behavior: `skills/legacy-to-spec/references/dependencies.md:25` and `references/workflow.md:5`.

Selecting first-convert for an available JSP dependency requires its full behavior to be converted in a separate scope. The checker traverses every Markdown/HTML artifact, but loads only the root specification and validates all HTML against the manifest's root scope. An independently scoped dependency prototype therefore fails even when its IDs correctly reference its own specification.

Reproduction: instantiated the existing harness test fixture in a temporary directory; added `artifacts/design/child/specification.md` defining SCR-02/ST-02/UI-02, `artifacts/renovation/child/{plan,tracking}.md`, and `artifacts/design/child/prototypes/screen.html` binding `data-scope-id="child"` with those IDs. No fixture sources or maintained files were changed. `check()` returned 1 with `WRONG_PROTOTYPE_SCOPE: child` plus `UNMAPPED_PROTOTYPE_ID` for all three IDs. The temporary package was removed.

Impact: compliant output from the first-convert route can fail sandbox structural validation, encouraging an incorrect merge into the root scope or omission of the dependency's visual output. Resolve scope/specification by each artifact's owning design directory or register additional scopes explicitly; retain the manifest root check for the root deliverable. Add a test for an authorized dependency JSP with its own scope and prototype.

Classification: concrete test infrastructure defect; the skill's single-JSP-scope rule itself is correct.

### W2 — P3: Acceptance/README assign planning content exclusively to tracking

Locations: `skills/legacy-to-spec/references/acceptance.md:19`; `README.md:50`. Related authority: `references/workflow.md:13-14`, `assets/renovation/plan.md:21-39`, `assets/renovation/tracking.md:3`.

The acceptance row says scheduling, progress, TODO details, source syntax, execution and history are “只在 tracking”; README likewise assigns work arrangements to tracking. The new workflow and templates intentionally put work order, task dependencies, impact, decisions and follow-up order in plan, with actual execution evidence in tracking.

Impact: following the acceptance wording literally would move required planning information to the wrong document or make a correctly populated plan fail manual acceptance. Update these sentences to distinguish plan ownership from tracking ownership while retaining the separation from system design.

Classification: internal instructional inconsistency. This does not establish a direct failure of the requested spec-versus-plan/tracking separation; both remain outside design specifications.

## Requirement assessment

| User requirement | Assessment and primary evidence |
| --- | --- |
| Philosophy contains no specific technology/framework/business detail | Met. `SKILL.md:6-59` uses responsibility, evidence and contract principles; specific JSP/eBAF/source syntax lives in references. Frontend/backend responsibility labels are general concepts, not a named technology or business domain. |
| YAML name/description, title, Goals and backend-style chapters | Met. `SKILL.md:1-8`, `:14`, `:20`, `:61`, `:77`, `:81`. Read only heading/metadata matches in supplied backend `.github/skills/ebaf2spec-trx-analyze/SKILL.md` and `.github/skills/spec2feature-plan/SKILL.md` to compare chapter structure. The latter contains the same Goals/Constraints/Rules/Workflow/Output Format/Evaluation Criteria structure. |
| One JSP per conversion scope | Met. `references/workflow.md:5`, `:30`; `references/dependencies.md:25`; tracking template `:10`. Harness limitation is W1. |
| Plan exists before dependency analysis | Met. `references/workflow.md:26`; `references/dependencies.md:5`; plan template `:3`, `:11`. No instruction permits retrospective plans to masquerade as prior plans. |
| Analyze external resources | Met. `references/dependencies.md:5-7` covers include/script/style/images/tags/messages/components/other entries/services and indirect dependencies; `source-analysis.md:9` adds analysis boundaries. |
| Every task records dependencies and impact | Met. `references/workflow.md:28`; plan template `:23-25`, with an explicit “none” dependency value rather than omission. |
| Reuse suitable neutral specifications | Met. `references/dependencies.md:11-17` requires source/version/authority/behavior/conditions/gap checks and direct references to suitable sections. |
| Unconverted resources appear in plan and dialogue with missing resource/impact and first-convert/defer choice | Met. `references/dependencies.md:21-26`; plan template `:17-19`, `:31-33`. It explicitly rejects file-only notification. |
| Reuse existing explicit authorization | Met. `references/dependencies.md:25`, `:28`; `references/workflow.md:28`. Sandbox policy is explicitly simulated and bounded. |
| Pending is not approval | Met. `references/dependencies.md:28`; plan template `:33`; tracking template `:84`. Silence/time do not become deferral authorization. |
| Deferred TODOs at affected design positions and plan follow-up | Met. `references/dependencies.md:26`; design template `:35`; tracking template `:84`; plan template `:27`. Index-only TODOs are expressly insufficient. |
| Specs separate from plans/tracking | Met. `references/workflow.md:11-16`; design template `:26`, `:34`, `:156`; plan and tracking have separate renovation paths. W2 requires wording alignment. |
| UI/components authority is frontend; API/backend authority is selected eBAF outputs | Met. `references/authority.md:5-13`, `:19-27`, `:31-35`; backend-reference `:24-36`; API template `:9-11`. `.github` examples are explicitly excluded as actual operation evidence. |
| Handle backend-coupled JSP | Met. `references/coupled-source.md:5-18`, `:24-44`; tracking LOGIC template `:53-59`; backend-handoff template `:24-53`. Includes initialization, trusted context, ordering, atomicity, unknown ownership and confirmed-backend-acceptance requirements. |

## Optional improvements, not requirement violations

- Structural validation checks plan file existence for schema version 2 (`scripts/skill-sandbox.py:179-183`) but not task/dependency/decision completeness. `test_sandbox_harness.py:94-102` intentionally accepts a one-line plan. Documentation correctly says structural pass does not establish semantics (`tests/legacy-to-spec/README.md:34-40`). Add targeted workflow assertions or an independent workflow review checklist if stronger automated evidence is needed; do not treat current structural PASS as proof of plan ordering or decisions.
- Existing tests validate default ask policy (`test_sandbox_harness.py:104-115`) but do not test generated first-convert/defer policy prompts separately. Add those tests to reduce policy-regression risk; current prompt definitions are explicitly bounded and correct (`scripts/skill-sandbox.py:89-91`).

## Limits

This audit checks maintained instructions, templates and infrastructure, not earlier generated sandbox deliverables or their source-based coverage. The only executed behavioral probe was the isolated multi-scope checker reproduction above. No backend business/API files were inspected; the supplied backend directory was used solely for chapter comparison.

## Resolution verification — 2026-10-12

The findings above describe the original audited state and are preserved. After the parent agent's corrections, independently re-read the maintained checker, harness tests, acceptance row and README wording, then ran the following verification. No other sandbox trials or reports were reviewed.

- **W1 resolved for the demonstrated scenario.** `scripts/skill-sandbox.py:225-251` now identifies the owner scope from each prototype's design path, reads that scope's specification, validates its own scope and IDs, requires `convert-available` for additional sandbox scopes and checks their separate plan/tracking documents. Independently repeated the child-scope reproduction with the explicit first-convert policy: checker returned **0 with no findings**. Removing the child's plan or tracking separately returned **1**, each with the correct `MISSING_DELIVERABLE` path. Setting policy to `ask` and `defer` separately returned **1 with `UNAUTHORIZED_DEPENDENCY_SCOPE`**, so pending/deferral is not treated as conversion authorization.
- **W2 resolved.** `skills/legacy-to-spec/references/acceptance.md:19` and `README.md:50` now assign task order/dependencies/impact/decisions to plan and evidence/source details/execution to tracking, while design retains the behavior contract and gap references.
- **Regression suite passed.** Executed `python3 tests/legacy-to-spec/test_sandbox_harness.py`: **11 tests passed**. The new tests at `:121-137` verify authorized dependency scope ownership and reject unauthorized additional scopes; the authorized case also rejects a child prototype ID borrowed only from the root specification.

No unresolved concrete finding remains from this audit. The optional workflow-completeness and prompt-policy coverage suggestions above remain optional. These checks establish the structural harness correction and wording consistency; they do not establish semantic completeness, plan creation chronology, actual user dialogue or backend integration of generated deliverables. All independently created probe directories were removed.
