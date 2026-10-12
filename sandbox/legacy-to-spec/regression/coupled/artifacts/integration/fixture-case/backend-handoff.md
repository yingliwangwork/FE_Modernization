# fixture-case: backend responsibility handoff

| Item | Record |
| --- | --- |
| Scope / version | fixture-case / renovation-v1 |
| Single root / evidence | `inputs/frontend/Case.jsp`, manifest-pinned UTF-8 source; E-001/E-002/E-005 |
| Frontend contract | [specification](../../design/fixture-case/specification.md) |
| Selected backend | `inputs/backend/api-contract.md` fixture-v1, selected by task.txt; E-010–E-012. Supporting `business-rules.md` fixture-v1 E-013. |
| Projection / evidence | [API spec](api-spec.md); [tracking](../../renovation/fixture-case/tracking.md) |
| Nature | Evidenced legacy requirements awaiting target coverage. No new operation, HTTP path, wire schema, storage design or framework is prescribed. |

## 1. Uncarried responsibilities

| Handoff | Responsibility | Logic / frontend links | Legacy evidence | Selected coverage / gap |
| --- | --- | --- | --- | --- |
| HANDOFF-001 | Reviewer initialization from trusted entry context | LOGIC-001; FLOW-001 / BOUND-003 / DATA-001 / UI-002 | E-001, E-003 | E-012 expressly does not carry reviewer initialization; TODO-001/004 |
| HANDOFF-002 | Supply legacy per-item ranking hint needed for display | LOGIC-008; FLOW-003 / BOUND-001 / DATA-006 / UI-008 | E-005 | E-011 defines only rowId/label; E-012 expressly does not carry rankHint; TODO-002 |
| HANDOFF-003 | Quantity parsing, charge tier, trusted unit storage, before rendering | LOGIC-002–005; FLOW-004/005 / BOUND-002 / BR-004 / DATA-008–011 | E-002, E-006, E-008 | E-012/013 do not carry quantity processing or storage; TODO-003/004/005/008 |

Missing supplied coverage does not establish that these capabilities do not exist elsewhere. Completion of this handoff document is not evidence of implementation or adoption.

## 2. Detailed needs

### HANDOFF-001: trusted reviewer initialization

Trigger: normal initial entry or commit entry (FLOW-001/005). Before the commit condition is evaluated and before rendering, the legacy source reads reviewer text from trusted session context. UI-002 displays `審閱者：` followed by that value (E-001, E-003). This ordering must remain visible in the decomposition; reviewer lookup is not a user-entered value or a fixed application default.

| Direction | Data / conceptual type | Requirement / consumer | Evidence / unknown |
| --- | --- | --- | --- |
| Trusted context input | DATA-001 reviewer text | Source name in session; no operator input | E-001; provenance/authentication TODO-004 |
| Presentation output | DATA-001 text | Display after label UI-002 during initial render | E-003; empty/null behavior and target initialization TODO-001 |

There is no evidenced permission condition, fallback reviewer label, remote call, or reviewer error message. AC-001 requires a supplied reviewer value to appear; absent-value behavior cannot be asserted. A backend delivery record mapping a legitimate trusted source to initialization is required before closing TODO-001. API-001 does not satisfy this need (E-012).

### HANDOFF-002: ranking hint per item

Trigger: recognized lookup success callback in FLOW-003. Existing table rows clear before insertion. Each legacy item is displayed as identifier, label, then ranking hint, in received collection order (E-005). The visible third-column header is `排序提示` (E-003). There is no evidence of a sorting algorithm, inferred numeric rank, or display computation from the identifier/name.

| Direction | Data / conceptual type | Requirement / consumer | Evidence / unknown |
| --- | --- | --- | --- |
| Returned item data | DATA-006 ranking hint; type/format unconfirmed | Per-item value consumed as text in UI-008 | E-005; TODO-002 |
| Display output | Text representation in third result column | Preserve alongside DATA-004/005; no added sort | E-003, E-005 |

The selected backend carries identifier/name only and explicitly does not carry this hint (E-011/E-012). Acquisition logic, business meaning, null/missing-value treatment and target representation remain unknown. AC-003 demonstrates legacy display with static synthetic hints; AC-013 confirms the target gap. Target coverage or an explicitly confirmed behavior change, rather than a fabricated response field, is required to close TODO-002.

### HANDOFF-003: quantity charging and storage

The screen's exact-empty validation is frontend responsibility (BR-003); backend processing is separate. Nonempty text reaches the legacy submission boundary, including whitespace/nonnumeric values, because no additional local validation is shown (E-006/E-008).

| Field | Requirement |
| --- | --- |
| Trigger / condition | ACT-002 enters with quantity commit instruction DATA-011. Exact selector `commit` is retained in the source mapping in tracking; all other selector values skip quantity processing. |
| Original order | First retrieve reviewer; then select commit branch; then parse quantity; then compute charge; then retrieve trusted unit for storage and invoke storage; only afterwards proceed to screen rendering if processing returns. |
| Trusted context | DATA-010 unit identity comes from server session, never an editable client field. The target search context definition does not alone prove adoption for quantity storage. |
| Required responsibility | Preserve legacy quantity-to-charge rule and storage invocation with unit, quantity, charge. No visible charge element, receipt or completion message exists in this source. |
| Target coverage | Selected API-001 and business rules cover lookup only, explicitly excluding quantity billing/storage. |
| Source / uncertainty | E-001/E-002/E-006/E-008/E-012/E-013. Storage implementation unavailable; target boundary, validation/errors and guarantees TODO-003/004/005/008. |

#### Input and output semantics

| Direction | Data | Conceptual type / known constraint | Source / destination | Evidence / gap |
| --- | --- | --- | --- | --- |
| Input | DATA-011 commit selection | Non-visible selection, exact commit branch | Quantity submission → entry processor | E-002, E-008 |
| Input | DATA-008 quantity | Text parsed as a signed integer by legacy backend; no business lower bound or positivity rule shown | Submitted quantity → parse step | E-002; exact accepted/error cases beyond source parse not runtime verified |
| Trusted context | DATA-010 unit | Legacy text context, target representation unknown | Server context → storage invocation | E-002; TODO-004 |
| Derived | DATA-009 charge | Integer, no currency/unit declared | Quantity tier calculation → storage invocation | E-002; cannot label currency or format |
| Side-effect request | Unit, integer quantity and charge | All three passed together | External storage dependency | E-002; actual persistence, atomicity and errors TODO-003/008 |

#### Conditions, order and side effects

| Step / branch | Known condition | Required processing | Outcome / exceptions / side effects |
| --- | --- | --- | --- |
| 1 | All entry paths | Obtain reviewer text | Before quantity branch and rendering; HANDOFF-001 |
| 2 | Selector is not commit, including absent selector | Skip parse/calculate/storage | Continue screen rendering; AC-014 |
| 3 | Selector is commit | Interpret quantity as integer | Parsing precedes calculation/storage. No local exception handler or user-facing parse message is supplied. Failure-visible outcome unknown. |
| 4a | Parsed quantity >= 4 | Charge = quantity × 8 | At quantity 4, charge 32 (AC-010) |
| 4b | Parsed quantity < 4 | Charge = quantity × 10 | At quantity 3, charge 30 (AC-009); no positivity constraint is added. |
| 5 | Parse/calculation reached storage | Invoke storage with trusted unit, quantity, computed charge | Actual storage implementation unavailable. A call is evidenced, persistence success is not. |
| 6 | Processing returns | Continue original screen rendering | No evidenced receipt, charge display, success message or returned storage result. |

All steps are supported by E-001/E-002; exceptions and side-effect guarantees remain TODO-003/005/008. No transaction, rollback, commit consistency, retry/idempotency or compensation rule is inferred. Do not replace this ordered responsibility by multiple client calls or local quantity charge arithmetic.

#### Adoption cases

| Case | Evidenced backend result to check | Screen contract | Limit |
| --- | --- | --- | --- |
| AC-009 | quantity 3 → charge 30 → invoke storage with trusted unit, 3, 30 | FLOW-005; no invented completion message | External storage and actual outcome unverified |
| AC-010 | quantity 4 → charge 32 → invoke storage with trusted unit, 4, 32 | FLOW-005 | Same limit |
| AC-014 | Noncommit entry skips quantity processing | FLOW-001 / normal rendering | No target entry mechanism prescribed |
| AC-007/008 | Empty screen input stops locally; nonempty text reaches boundary | FLOW-004, MSG-003 | Passing local check never proves backend quantity validity |

## 3. Adoption evidence index

| Handoff | Reviewed selected artifact / version | Confirmed adoption | Remaining condition |
| --- | --- | --- | --- |
| HANDOFF-001 | API contract fixture-v1 E-012 | None in supplied selected baseline | Trusted reviewer result and initialization mapping; TODO-001/004 |
| HANDOFF-002 | API contract fixture-v1 E-011/E-012 | Identifier/name only under API-001; hint not carried | Ranking hint coverage or approved visible change; TODO-002 |
| HANDOFF-003 | API contract and business rules fixture-v1 E-012/E-013 | None for quantity processing | Explicit parsing/tier/storage/context coverage and verification, exception/transaction limits; TODO-003/004/005/008 |

No TODO is closed by documenting a handoff. Future adoption must update API consumption, affected FLOW/DATA/BR/AC, and recorded validation in tracking while preserving original evidence and IDs.
