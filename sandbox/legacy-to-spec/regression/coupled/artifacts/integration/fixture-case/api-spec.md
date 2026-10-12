# fixture-case: API consumption specification

| Item | Baseline / scope |
| --- | --- |
| Scope / projection version | fixture-case / renovation-v1 |
| Frontend contract | [specification](../../design/fixture-case/specification.md) |
| Authoritative selected backend | `inputs/backend/api-contract.md`, fixture-v1; SHA-256 `04215f381bc195b357b184c89d90e6f4fba521580feb7147c141a25cdb1ca802`; selected explicitly by task.txt. Backend root `inputs/backend`. |
| Supporting business authority | `inputs/backend/business-rules.md`, fixture-v1; E-013. Does not define extra exchange fields or operations. |
| Nature / environment | Sandbox backend delivery contract, explicitly not a formal service; no callable environment provided. Deployment status unconfirmed. No calls performed. |
| Common contract | Same selected document defines JSON media, body/envelope, and HTTP 200 outcomes. Authentication transmission, other HTTP responses and security headers are undefined (TODO-004/005). |
| Evidence / progress | [tracking](../../renovation/fixture-case/tracking.md); [handoff](backend-handoff.md). |

## 1. Consumer needs and operation index

| Frontend need | Capability / projection | Selected identity | Evidence |
| --- | --- | --- | --- |
| FLOW-002/003, BOUND-001 | Lookup permitted items with optional keyword | API-001: searchItems, fixture-v1 | E-004, E-005, E-010–E-013 |
| FLOW-001, BOUND-003 | Reviewer initialization | No supplied operation; HANDOFF-001 | E-001, E-003, E-012 |
| FLOW-003, DATA-006 | Ranking hint in each row | Not carried by selected response; HANDOFF-002 | E-005, E-012 |
| FLOW-004/005, BOUND-002 | Quantity parsing, tier charge and storage | No supplied operation; HANDOFF-003 | E-002, E-006, E-008, E-012 |

## 2. Confirmed API projection

### API-001: searchItems

#### Operation and transport

| Item | Exact selected definition | Evidence / limit |
| --- | --- | --- |
| operationId | `searchItems` | E-010 |
| Method / path | `POST /v2/items/search` | E-010; no compatibility path specified |
| Request / response media | `application/json` | E-010 |
| Body encoding | Request body is an object | E-010 |
| Headers | Media type is defined; exact header set, authentication/security header names and credentials are not supplied. Do not infer an Authorization bearer scheme. | E-010; TODO-004 |
| Unit context | Server context provides business unit; client `unitId` is not accepted | E-010, E-013; context provenance TODO-004 |
| Nature / environment | fixture-v1 sandbox delivery contract, non-formal service, no callable environment | E-010; deployment unconfirmed |
| Timing / guarantees | Retry, idempotency, timeout, cancellation, pagination, ordering, transaction guarantees not defined | E-013; TODO-008 |

#### Request and source mapping

| Wire location / path | Backend type / format | Required / absence / empty / null | Frontend legitimate source | Transformation and timing | Evidence |
| --- | --- | --- | --- | --- | --- |
| body | object | Body definition provided; whether the entire body can be omitted is not defined | FLOW-002 produces request with keyword field | No invented envelope | E-010, E-004 |
| body.queryText | string, max length 12 | Optional; missing or `""` means unspecified keyword. `null` invalid. No default value fabricated. | DATA-002 / UI-003 → DATA-003 | Trim leading/trailing whitespace at lookup without mutating visible input; map legacy `search_word` to `queryText` under explicit backend equivalence | E-003, E-004, E-010, E-012 |
| server context unit (not body field) | Context unit identity; wire type undefined | Business execution requires context; do not send client `unitId` | Trusted backend context DATA-010; never an editable UI or copied client hidden field | Supplied/validated by backend | E-010, E-013; TODO-004 |

The frontend evidence establishes a 12-character input limit and trimming; backend max-length/null acceptance rules are independent. No undocumented client numeric, keyword-required or unit entry control is introduced. Exact handling of additional properties besides the explicitly disallowed client `unitId` is not defined.

#### Complete known response and consumption mapping

| Wire path | Backend type / requirements | Meaning | Frontend consumer / transition | Evidence / gap |
| --- | --- | --- | --- | --- |
| HTTP 200 body | object | Response root, without an extra payload/envelope layer | FLOW-003 | E-011 |
| body.outcome | required string | `OK`, `EMPTY`, `DENIED` | DATA result branch → TR-003/004/005, ST-003/004/005 | E-005, E-011, E-012 |
| body.rows | required array | Returned item collection; empty for EMPTY/DENIED | DATA-007 / UI-009, replace existing rows at callback | E-005, E-011, E-012 |
| body.rows[].rowId | required string in every row object | Item identifier | DATA-004 / UI-006; direct text display | E-005, E-011, E-012 |
| body.rows[].label | required string in every row object | Item label | DATA-005 / UI-007; direct text display | E-005, E-011, E-012 |

Rows are objects; no other row property is defined. The contract does not specify nullable alternatives for the required string/array fields. There are no known output fields omitted by this projection. There is no confirmed `rankHint`, `unitId`, charge, reviewer, success flag or message in this response. `DATA-006` is a frontend need and remains a gap; it is not added to the backend schema.

#### Results and visible reactions

| Transport | Outcome / known condition | Body facts | UI behavior | Evidence |
| --- | --- | --- | --- | --- |
| HTTP 200 | `OK`; service permits lookup and has items | Known `rows` objects above | Clear previous rows, render identifier/name in received order. Legacy third-column hint still lacks target mapping. No success message is supplied. | E-005, E-011–E-013; TODO-002 |
| HTTP 200 | `EMPTY`; permitted but no matching items | `rows=[]` | Clear rows, show exact frontend MSG-001 `沒有項目` in status, ST-004 | E-005, E-011–E-013 |
| HTTP 200 | `DENIED`; service context unit not permitted | `rows=[]` | Clear rows, show exact frontend MSG-002 `不允許查閱` in status, ST-005 | E-005, E-011–E-013 |
| Unspecified | Other outcomes / non-200 / transport or decoding failure | Not defined by selected backend | No invented error envelope, code, notification, retry or fallback. Legacy other-result callback exists independently, without proving target support. | E-005, E-011; TODO-005 |

The selected source's `DENIED` description uses `不允許查阅`; this is backend descriptive text, not a response message field. The frontend's fixed displayed text remains `不允許查閱`. HTTP 200 is distinct from lookup permission and data availability.

#### Order and responsibility

| Consumer | Before request | Backend responsibility | After response | Limit |
| --- | --- | --- | --- | --- |
| FLOW-002/003, BOUND-001 | Clear status; trim keyword; preserve rows/input; send keyword | Determine lookup permission by server unit and retrieve items | Clear table then branch; direct text rendering; do not independently clear status in success/unknown callback | E-004, E-005, E-010–E-013. Auth, hint, concurrency and service guarantees remain TODO-002/004/005/008. |

A repeated UI lookup has no sourced local guard. This does not establish backend retry safety, order, or idempotency. There is no confirmed transaction across search and quantity submission and no client orchestration proposed to replace one.

#### Contract case index

| Case | Projection check | Frontend expectation | Definition / evidence |
| --- | --- | --- | --- |
| AC-002, AC-011 | Keyword rename, trim, max length, omission/empty vs null | Visible input retained; blank lookup allowed | Specification §8; E-003, E-004, E-010, E-012 |
| AC-003, AC-013 | `OK`, rowId/label fields only | Direct first two columns; hint gap preserved | Specification §8; E-005, E-011, E-012 |
| AC-004, AC-005 | `EMPTY`/`DENIED`, `rows=[]` | Exact sourced empty/denied frontend messages | Specification §8; E-005, E-011–E-013 |
| AC-006, AC-012 | No invented target other code or ordering guarantees | Legacy callback behavior remains separate | Specification §8; E-004, E-005, E-011, E-013 |

## 3. Needs without a usable target contract

| Frontend need | Confirmed need | Missing target contract | Handoff / tracking |
| --- | --- | --- | --- |
| BOUND-003 / FLOW-001 / DATA-001 | Dynamic trusted reviewer text before initial render | No selected reviewer initialization coverage | HANDOFF-001 / TODO-001 |
| FLOW-003 / DATA-006 / UI-008 | Legacy per-item ranking hint shown in third column | No response definition, type, data source or semantics | HANDOFF-002 / TODO-002 |
| BOUND-002 / FLOW-004/005 | Parse quantity, tier charge, store with trusted unit before render | No selected commit operation, result contract or storage dependency definition | HANDOFF-003 / TODO-003 |
| BOUND-001 / DATA-010 | Trusted unit and authentication | Authentication transmission and context provenance undefined | TODO-004; no frontend input fabricated |
| BOUND-001 / FLOW-003 | Real external failure handling | No non-200/error/malformed-response contract | TODO-005; no new endpoint or error schema |

Only Markdown backend sources were supplied. No machine-readable OpenAPI was supplied or generated; no parser result is claimed for this document. This projection is a document comparison, not a verified integration or evidence of deployment.
