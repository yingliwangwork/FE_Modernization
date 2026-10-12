# 項目查閱: front-end behavior specification

| Item | Contract |
| --- | --- |
| Scope / version | fixture-case / renovation-v1 |
| System boundary | One item lookup screen: initial reviewer display, keyword lookup, result display, and quantity submission up to its unconfirmed outcome. |
| Reading links | [Evidence and tracking](../../renovation/fixture-case/tracking.md), [prototype](prototypes/SCR-001.html), [API consumption](../../integration/fixture-case/api-spec.md), [backend handoff](../../integration/fixture-case/backend-handoff.md). |
| Contract status | Partial: reviewer initialization, ranking hints, quantity processing, and some external failure behavior lack target contracts. |

Evidence IDs below resolve to the [evidence register](../../renovation/fixture-case/tracking.md#3-evidence-register). This describes source-defined behavior, without claiming observation of a running legacy screen.

## 1. Purpose and boundary

### 1.1 Confirmed responsibilities

The screen permits an operator to request items and send a quantity (E-003, E-004, E-007). A wider business purpose, named operator role, and purpose of the quantity charge are unconfirmed (TODO-009). No business intention is inferred from the page title or the control names.

### 1.2 Functional scope

| Boundary | Included behavior | Stop boundary | Evidence |
| --- | --- | --- | --- |
| Screen | Reviewer line, keyword, lookup action, status, three-column results, quantity and submit action. | SCR-001 only. | E-003, E-007, E-009 |
| BOUND-001 | Request item lookup and consume its known result branches. | Service-side permission and item retrieval belong to the selected backend. | E-004, E-005, E-010, E-011, E-012 |
| BOUND-002 | Deliver a nonempty quantity for quantity charging and storage. | No confirmed target operation or visible completion result. | E-002, E-006, E-008, E-012 |
| BOUND-003 | Obtain the reviewer name used in the initial display. | Trusted initialization and missing-name behavior remain unconfirmed in the target. | E-001, E-003, E-012 |

### 1.3 Contract gaps

| Gap | Affected contract | Tracking |
| --- | --- | --- |
| Reviewer initialization and missing values | DATA-001, FLOW-001, UI-002, BOUND-003 | [TODO-001](../../renovation/fixture-case/tracking.md#todo-001) |
| Ranking hint is needed by the existing screen but absent from selected response | DATA-006, UI-008, FLOW-003 | [TODO-002](../../renovation/fixture-case/tracking.md#todo-002) |
| Quantity charging/storage not carried by selected backend; storage dependency unavailable | FLOW-004, FLOW-005, BOUND-002, DATA-009 | [TODO-003](../../renovation/fixture-case/tracking.md#todo-003) |
| Authentication transport and trusted context provenance | DATA-010, BOUND-001, BOUND-002 | [TODO-004](../../renovation/fixture-case/tracking.md#todo-004) |
| Transport failure, malformed responses, exceptions and concurrency guarantees | FLOW-002, FLOW-003, FLOW-005 | [TODO-005](../../renovation/fixture-case/tracking.md#todo-005) |
| Legacy execution, browser display, keyboard/focus/return/cancel behavior | SCR-001, AC-001–AC-012 | [TODO-006](../../renovation/fixture-case/tracking.md#todo-006), [TODO-007](../../renovation/fixture-case/tracking.md#todo-007) |
| Service timing, retries, ordering, pagination, transaction guarantees | BOUND-001, BOUND-002 | [TODO-008](../../renovation/fixture-case/tracking.md#todo-008) |
| Wider business intention and user roles | This scope | [TODO-009](../../renovation/fixture-case/tracking.md#todo-009) |

## 2. Actors and system context

| ID | Trigger source | Event / restrictions | Evidence |
| --- | --- | --- | --- |
| ACT-001 | Screen operator; role is not identified | FLOW-002 lookup, FLOW-004 quantity submission. Both buttons are rendered; that establishes no service authorization. | E-003, E-007, E-008; TODO-009 |
| ACT-002 | Screen entry lifecycle | FLOW-001 initialization; FLOW-005 on entry with a quantity commit instruction. | E-001, E-002 |
| ACT-003 | Item lookup service response | FLOW-003 response arrival. The selected backend decides lookup permission using its trusted unit context. | E-005, E-010, E-011, E-013 |

On normal first entry, the reviewer value is obtained before display; the keyword and quantity have no supplied initial value, the status is empty and the result table has no rows (E-001, E-003, E-007, E-008). Entry carrying a quantity commit instruction additionally triggers FLOW-005 before rendering (E-002). No additional entry route or role-specific rendering is established.

## 3. Data semantics and boundaries

### 3.1 Data dictionary

| ID | Meaning / consumer | Conceptual type / constraints | Source and lifetime | Evidence / gap |
| --- | --- | --- | --- | --- |
| DATA-001 | Reviewer name / UI-002 | Text; absence behavior unconfirmed | Trusted entry context, rendered before interactions | E-001, E-003; TODO-001 |
| DATA-002 | Entered keyword / UI-003 | Text, input length limit 12; empty permitted | Initially empty, editable; preserved by lookup | E-003, E-004 |
| DATA-003 | Lookup keyword / BOUND-001 | Text with leading/trailing whitespace removed | Derived at each lookup; empty means no keyword in selected contract | E-004, E-010, E-012 |
| DATA-004 | Item identifier / UI-006 | Text; exact display, no formatting added | Each returned item | E-005, E-011, E-012 |
| DATA-005 | Item name / UI-007 | Text; exact display | Each returned item | E-005, E-011, E-012 |
| DATA-006 | Ranking hint / UI-008 | Legacy display value; type, format and business interpretation unconfirmed | Each legacy item; not supplied by selected backend | E-005, E-012; TODO-002 |
| DATA-007 | Lookup result list | Ordered collection as received, without client sorting | Existing rows preserved until a response; then replaced/cleared | E-004, E-005 |
| DATA-008 | Quantity / UI-010 | Text on entry; only exact empty text is rejected by the screen. No screen length, positivity or numeric validation is evidenced. | Initially empty, retained through local rejection and boundary demonstration | E-006, E-008 |
| DATA-009 | Computed charge / BOUND-002 | Integer; business calculation delegated in HANDOFF-003 | Quantity processing before storage; not displayed by this screen | E-002; TODO-003 |
| DATA-010 | Trusted unit identity | Text in the legacy context; target context transport/provenance unconfirmed | Backend authority, never operator-editable | E-002, E-010, E-013; TODO-004 |
| DATA-011 | Quantity commit instruction | Non-visible action selection | Quantity submission and entry processing only | E-002, E-008 |

### 3.2 Boundary contracts

| ID | Trigger and other party's responsibility | Outgoing data | Known result and screen effect | Evidence / gap |
| --- | --- | --- | --- | --- |
| BOUND-001 | FLOW-002; service decides permission and retrieves items | DATA-003 only; unit is supplied by server context | FLOW-003 renders results or the exact empty/denied message. API-001 defines selected transfer contract. | E-004, E-005, E-010–E-013; TODO-002, TODO-004, TODO-005 |
| BOUND-002 | FLOW-004/005; backend parses quantity, computes charge, stores with trusted unit | DATA-008 and DATA-011; trusted DATA-010 belongs to backend | Legacy processing occurs before screen rendering; visible success/error text, resulting stored state and target exchange are unknown. HANDOFF-003 preserves responsibility. | E-002, E-006, E-008; TODO-003 |
| BOUND-003 | FLOW-001; trusted initial reviewer lookup | No operator input | DATA-001 shown in UI-002; HANDOFF-001 covers missing target initialization | E-001, E-003, E-012; TODO-001 |

Exact transfer definitions belong only in the [API consumption document](../../integration/fixture-case/api-spec.md).

## 4. Screen and experience

### 4.1 Screen composition

SCR-001 is titled `項目查閱`. In order: heading, `審閱者：` and dynamic reviewer, `關鍵字` and input, lookup action bar, status paragraph, table headed `項目代碼` / `名稱` / `排序提示`, then `數量` input and `送出數量` action. There are no evidenced conditional visibility restrictions in these supplied blocks (E-003, E-007, E-008).

### 4.2 Elements

| ID | Order / visible label | Conditions and data | Reaction | Evidence |
| --- | --- | --- | --- | --- |
| UI-001 | Heading: 項目查閱 | Always in supplied screen | Display only | E-003 |
| UI-002 | 審閱者： followed by name | DATA-001 | Display only | E-001, E-003 |
| UI-003 | 關鍵字 / text entry | DATA-002; limit 12; optional | Value consumed by FLOW-002 | E-003, E-004 |
| UI-004 | 查閱 | CMP-001; rendered without permission guard | FLOW-002 | E-007 |
| UI-005 | Status paragraph | Initially empty; MSG-001/002 | Cleared at lookup trigger; set on recognized response | E-004, E-005 |
| UI-006 | 項目代碼 column | DATA-004 | Display each returned item | E-005, E-003 |
| UI-007 | 名稱 column | DATA-005 | Display each returned item | E-005, E-003 |
| UI-008 | 排序提示 column | DATA-006; target content unknown | Preserve column and known legacy display, no inferred rank calculation | E-003, E-005; TODO-002 |
| UI-009 | Result table/body | DATA-007; initially no rows | FLOW-003 replaces rows on any callback | E-005, E-003 |
| UI-010 | 數量 / text entry | DATA-008 | FLOW-004 checks exact empty text | E-006, E-008 |
| UI-011 | 送出數量 | No evidenced disabling | FLOW-004 | E-006, E-008 |
| UI-012 | Empty-quantity alert | MSG-003 | Acknowledgment returns to existing screen; submission stops | E-006 |

### 4.3 Operation experience and visual limits

Source style specifies sans-serif text, screen width at most 720 pixels, margin 24 pixels, text color #222, a full-width table with collapsed borders, 16-pixel vertical table margins, 1-pixel #555 cell borders, 6-pixel cell padding and left alignment. The action bar has an 8-pixel top margin (E-009). No source-specific input dimensions, brand imagery, breakpoint, animation, focus program, keyboard shortcut, return or cancellation contract is known (TODO-007). Lookup clears only the status before sending, preserving previous rows until response; input values remain unchanged (E-004, E-005). Repeated lookups are not blocked by these source handlers; ordering guarantees are not established (TODO-005, TODO-008).

### 4.4 Shared component

CMP-001 is the lookup action bar, version matching E-007/E-009. In this scope it receives no parameters, renders UI-004 below the keyword with 8-pixel top spacing, and invokes FLOW-002. No alternate use or global component library behavior is claimed.

## 5. States and transitions

Quantity and search states are independent; the same table and inputs remain present during quantity validation. The prototype exposes the current event state plus `data-search-state-id` and `data-quantity-state-id` so previous search results are not lost during a quantity boundary event.

| ID | Condition | Visible state / preserved data | Evidence |
| --- | --- | --- | --- |
| ST-001 | Normal initial entry | Empty keyword, status, table and quantity; dynamic reviewer displayed | E-001, E-003, E-008 |
| ST-002 | Lookup sent, callback not received | Status empty; previous rows, keyword and quantity retained; no sourced spinner or disabling | E-004, E-005 |
| ST-003 | Recognized item-success response | Returned rows in received order, including legacy ranking hint; status normally empty | E-005; TODO-002 |
| ST-004 | Recognized no-items response | Empty table, MSG-001 | E-005 |
| ST-005 | Recognized denied response | Empty table, MSG-002 | E-005 |
| ST-006 | Other legacy result value reaches callback | Empty table; callback sets no message; existing status is unchanged by that callback | E-005; target other result codes are undefined |
| ST-007 | Empty quantity rejected, alert acknowledged | Existing inputs, table and status unchanged; no quantity handoff | E-006 |
| ST-008 | Nonempty quantity accepted by screen check | Submission reaches boundary; target terminal visible result unknown | E-006, E-008; TODO-003 |

| Transition | Start | Event and response | End | Flow / evidence |
| --- | --- | --- | --- | --- |
| TR-001 | Entry | Obtain reviewer and render normal initial content | ST-001 | FLOW-001 / E-001, E-003 |
| TR-002 | Any search state | Lookup: clear status, trim keyword, hand off; do not clear rows | ST-002 | FLOW-002 / E-004 |
| TR-003 | Awaiting response or another current search state | Callback: clear rows, then render each success item | ST-003 | FLOW-003 / E-005 |
| TR-004 | As above | Callback: clear rows, set 沒有項目 | ST-004 | FLOW-003 / E-005 |
| TR-005 | As above | Callback: clear rows, set 不允許查閱 | ST-005 | FLOW-003 / E-005 |
| TR-006 | As above | Callback: clear rows; no recognized branch | ST-006 | FLOW-003 / E-005 |
| TR-007 | Any screen/search state | Submit exact empty quantity: show alert, block submission | ST-007, previous search state preserved | FLOW-004 / E-006 |
| TR-008 | Any screen/search state | Submit other quantity text: allow handoff | ST-008; terminal result unconfirmed | FLOW-004 / E-006, E-008 |
| TR-009 | Entry with commit instruction | Parse quantity, compute charge, store, then render if processing returns | Visible terminal state unknown until successful rendering; no invented success | FLOW-005 / E-002; TODO-003 |

## 6. Rules and messages

| Rule | Condition and ordered response | Evidence / gap |
| --- | --- | --- |
| BR-001 | Lookup input is limited to 12 entered characters. At lookup, strip boundary whitespace for the outgoing value without rewriting the input. | E-003, E-004, E-010, E-012 |
| BR-002 | Clear status before lookup; clear table only after response arrives, before result branch selection. Preserve row order as received; no sorting inferred from 排序提示. | E-004, E-005 |
| BR-003 | Exact empty quantity text shows MSG-003 and prevents submission. Any other text, including whitespace, passes this screen check; backend validity is separate. | E-006 |
| BR-004 | Quantity charging and storage precede subsequent rendering in the legacy commit path. Backend owns computation and trusted unit context; see HANDOFF-003. | E-002; TODO-003 |
| BR-005 | Selected lookup backend determines permission from server unit context; UI button visibility does not establish permission. | E-007, E-010, E-013 |

| Message | Exact visible text | Trigger / position / persistence | Evidence |
| --- | --- | --- | --- |
| MSG-001 | 沒有項目 | No-items branch; UI-005. Cleared on next lookup trigger, or replaced by a response that sets a message. | E-004, E-005 |
| MSG-002 | 不允許查閱 | Denied branch; UI-005. Same clear/replace behavior as MSG-001. | E-004, E-005 |
| MSG-003 | 數量不得為空 | Exact empty-quantity submission; modal alert UI-012, submission blocked after acknowledgment. | E-006 |

A success or unrecognized callback does not independently clear the status: status was cleared by the lookup trigger. For overlapping calls, a previous callback can have set status before another success/unknown callback; the latter then leaves that status text intact (E-004, E-005). No generic failure or submission-success message is established.

## 7. Triggered flows

### FLOW-001: Initial screen entry

ACT-002 enters without a commit instruction. Retrieve DATA-001 from trusted context (BOUND-003), then render SCR-001 in source order. Initial table, status, keyword and quantity are empty. This is presentation plus missing backend initialization HANDOFF-001. Missing reviewer values and origin/authentication of the trusted context are unknown, not replaced by an application default (E-001, E-003, E-008; TODO-001, TODO-004). TR-001 ends in ST-001.

### FLOW-002: Request item lookup

ACT-001 activates UI-004 from any displayed search state. First clear UI-005. Read DATA-002 and remove leading/trailing whitespace to form DATA-003; hand it to BOUND-001/API-001. Keep UI-009 and both inputs untouched while awaiting callback (ST-002/TR-002). No client disable, loading message or duplicate suppression is evidenced. The selected backend checks permission and retrieves items; authentication transport remains unknown. A transport or decoding failure's visible result is unknown (E-004, E-007, E-010, E-013; TODO-004, TODO-005).

### FLOW-003: Consume an item response

ACT-003 delivers a response to a lookup. First clear every displayed result row. Then select in order: item-success → insert identifier, name, ranking hint for every item in supplied order (TR-003/ST-003); no-items → MSG-001 (TR-004/ST-004); denied → MSG-002 (TR-005/ST-005); other legacy result → no additional operation (TR-006/ST-006). Success and other-result callbacks do not reset status. The selected target contract maps its three known outcomes into those first three branches, but has no ranking hint; HANDOFF-002 remains required. Other legacy results are shown only as a source-defined branch, not a target result-code extension. No item click/navigation is defined (E-005, E-011, E-012; TODO-002, TODO-005).

### FLOW-004: Validate quantity before handing off

ACT-001 activates UI-011. Compare DATA-008 with exact empty text. If empty, display MSG-003, then terminate without handoff, retaining all existing screen data (TR-007/ST-007). Otherwise permit BOUND-002 with DATA-008 and non-visible DATA-011 (TR-008/ST-008). Whitespace, nonnumeric and signed input are not rejected by this screen check. No success screen or stored result can be inferred from allowing submission (E-006, E-008; TODO-003).

### FLOW-005: Quantity commit entry processing

ACT-002 receives DATA-011 selecting commit. After reviewer retrieval and before rendering, interpret DATA-008 as an integer, compute DATA-009 under the legacy tier rule, and request storage with trusted DATA-010. HANDOFF-003 retains the exact rule and order. If the action selector is not commit, these three processing steps are skipped. If processing returns normally, rendering proceeds with the same source-defined empty inputs/status/table and reviewer line. Parsing/storage exception outcomes and persistence guarantees remain unknown because the storage dependency and running environment were not supplied. This is a backend flow, never a prototype calculation or storage operation (E-001, E-002; TODO-003, TODO-005, TODO-008).

## 8. Acceptance case definitions

These are expected contracts, not claims of executed browser or backend tests. All values below are synthetic examples.

| Case | Flow / branch | Setup and event | Expected result / boundary | Evidence / gap |
| --- | --- | --- | --- | --- |
| AC-001 | FLOW-001/TR-001 | Normal entry with supplied reviewer text 展示審閱者 | Exact screen order; reviewer displayed, inputs/status/table empty | E-001, E-003, E-007–E-009; target initialization TODO-001 |
| AC-002 | FLOW-002/TR-002 | Existing rows and status; keyword `  示例  `; click 查閱; hold response | Status clears immediately; outgoing semantic keyword `示例`; input remains `  示例  ` and old rows remain | E-004, E-012 |
| AC-003 | FLOW-003/TR-003 | Release success response with two synthetic rows | Two rows in received order with identifier/name and known legacy hint; no client sort; status untouched by callback | E-005; target hint TODO-002 |
| AC-004 | FLOW-003/TR-004 | Existing rows; release no-items response | All rows removed, 沒有項目 displayed | E-005, E-011, E-012 |
| AC-005 | FLOW-003/TR-005 | Existing rows; release denied response | All rows removed, 不允許查閱 displayed | E-005, E-011, E-012 |
| AC-006 | FLOW-003/TR-006 | Existing rows; unknown legacy result callback | Rows removed, no message added; not a selected backend outcome | E-005; TODO-005 |
| AC-007 | FLOW-004/TR-007 | Quantity empty; click 送出數量, acknowledge alert | 數量不得為空; no handoff, prior results/status retained | E-006 |
| AC-008 | FLOW-004/TR-008 | Quantity ` `, `abc`, `3` or `4`; submit separately | Each passes exact-empty check and reaches boundary; no screen numeric validation or success assertion | E-006, E-008; TODO-003 |
| AC-009 | FLOW-005/TR-009 | Commit instruction with quantity 3 and trusted unit | Backend handoff requires charge 30 then store with same unit and quantity; visible outcome unknown | E-002; HANDOFF-003/TODO-003 |
| AC-010 | FLOW-005/TR-009 | Commit instruction with quantity 4 and trusted unit | Backend handoff requires charge 32 then store with same unit and quantity; visible outcome unknown | E-002; HANDOFF-003/TODO-003 |
| AC-011 | FLOW-002/BR-001 | Enter 12 characters; attempt a thirteenth; lookup blank/whitespace-only keyword | Native input limit 12; trimmed empty outgoing value; selected contract permits empty/omitted keyword, rejects null | E-003, E-004, E-010, E-012 |
| AC-012 | FLOW-002/003 | Two lookup triggers, hold callbacks; release denied then success | Both triggers accepted locally; each callback clears rows. The success callback can leave previous denied status; no new race guard is introduced. | E-004, E-005; server/concurrency guarantees TODO-005/008 |
| AC-013 | API-001 | Known target result supplies identifier and name only | Identifier/name map to UI; ranking hint remains a documented gap, never fabricated in target schema | E-005, E-011, E-012; TODO-002 |
| AC-014 | FLOW-005 | Entry instruction other than commit | Quantity parsing/calculation/storage not entered | E-002 |

## 9. Prototype index

| File | Screen / states | Demonstration steps | Synthetic data / limits |
| --- | --- | --- | --- |
| [SCR-001.html](prototypes/SCR-001.html) | SCR-001; ST-001–ST-008 | Open for initial screen. In separate 審閱工具 select legacy success/no-items/denied/unknown or target success fixture. Click 查閱. Enable 延後回應 to observe status clear/old rows retained; release next response using review tool. Submit empty quantity for sourced alert; nonempty quantity stops at documented handoff. Reset restores initial view. | Reviewer and two complete legacy rows are explicit synthetic fixtures. Ranking hints are prewritten legacy display samples; target fixture contains only confirmed identifier/name data and leaves hint cells blank with review-layer TODO-002 disclosure. No backend calculations, trusted-state derivation, storage or connections. Held/delivered responses are review tools, not product controls. Browser/legacy visual comparison unexecuted. |

## 10. Frontend/backend responsibility allocation

| Frontend behavior | Confirmed target responsibility | Unconfirmed responsibility |
| --- | --- | --- |
| Lookup trim, table/status updates, keyword limit | API-001 permission/retrieval and exact response fields | Ranking hint HANDOFF-002; authentication TODO-004 |
| Reviewer text presentation | No selected initialization coverage | HANDOFF-001 |
| Quantity empty-text alert and submission trigger | No selected quantity processing coverage | HANDOFF-003: parse, charge, storage, trusted unit |
| Shared lookup button and source style | Backend does not define component appearance | Browser fidelity TODO-006; unknown focus/cancel/return TODO-007 |

Evidence: E-001–E-013. Exact exchange facts remain in API-001; source symbols, dependency inventory, execution results and TODO work details remain in tracking. The selected backend is a fixture contract with no callable environment; deployment status is unconfirmed.
