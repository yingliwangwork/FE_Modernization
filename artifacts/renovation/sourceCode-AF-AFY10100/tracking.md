# sourceCode-AF-AFY10100：翻新執行與持續追蹤

[plan](plan.md)；[系統規格](../../design/sourceCode-AF-AFY10100/specification.md)。本輪部分交付，DEC-02已確認先翻新共用依賴、明細內部延後；auto=all 只涵蓋本 scope 已列明 TASK-02–08。

## 1. 來源與分析邊界

唯一根入口 `sourceCode/AF/AFY10100.jsp`；Git `4ef5c093ecad200b454109fddaef2f4b168dfacd`；SHA-256 `a539bd59d154a436b77f01466661601fd31825474454e52df949f7931ba5cee9`；108712 bytes；2013物理行，全CRLF。BIG5 宣告、cp950 嚴格解碼及可讀中文相符；UTF-8 嚴格失敗偏移960。inventory 的 encoding_conclusion 原樣保留未確認，分析選用 cp950，未冒充工具已判定。UTF-8 副本 [entry.utf8.txt](entry.utf8.txt) 同行號，原件未修改。

分析日期 2026-10-12–13（Asia/Taipei）；執行者 Codex。分析本頁所有2013行。其他 JSP 不作第二根入口；共用header／訊息已嚴格解碼並分析本頁所用分支。其依賴的tag／字型／正式環境資料未取得仍有缺口；完整來源編碼与版本見各inventory。後端根、版本、來源性質與適用環境未取得；部署狀態未確認。

範本各角色路徑／SHA-256 見 [template-selection.json](template-selection.json)。採用 plan、tracking、specification、prototype、component-design/css、tokens、api-spec、backend-handoff 所需資訊；以更緊湊章節維持證據、流程、資料、樣式、驗收與缺口。樣式格式 2026-10-12 查閱 [DESIGN.md alpha](https://github.com/google-labs-code/design.md/blob/main/docs/spec.md) 与 [DTCG 2025.10](https://www.designtokens.org/tr/2025.10/format/)，僅採用已知值与所用 token 型別，不宣稱完整官方 validator 通過。

## 2. 證據登錄

<a id="e-01"></a>

### E-01

原件 `sourceCode/AF/AFY10100.jsp:1–33`，上述 SHA-256；最小定位與事實：編碼、共用來源引入及全頁背景。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-02"></a>

### E-02

原件 `sourceCode/AF/AFY10100.jsp:35–91`，上述 SHA-256；最小定位與事實：標題定位、快捷鍵註冊、驗證規則及初始化順序。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-03"></a>

### E-03

原件 `sourceCode/AF/AFY10100.jsp:94–119`，上述 SHA-256；最小定位與事實：查詢、刪除、修改與取回的整份表單交接。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-04"></a>

### E-04

原件 `sourceCode/AF/AFY10100.jsp:120–141`，上述 SHA-256；最小定位與事實：先驗證，再檢核識別值；Y 確認／取消及非 Y 分支。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-05"></a>

### E-05

原件 `sourceCode/AF/AFY10100.jsp:144–226`，上述 SHA-256；最小定位與事實：選列逐欄回填、啟用三按鈕、顯示編輯區與造字呼叫。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-06"></a>

### E-06

原件 `sourceCode/AF/AFY10100.jsp:228–313`，上述 SHA-256；最小定位與事實：取消清空欄位、解除所有選取、禁用三按鈕並隱藏編輯區。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-07"></a>

### E-07

原件 `sourceCode/AF/AFY10100.jsp:315–369`，上述 SHA-256；最小定位與事實：明細參數、新視窗及無明示 URL 編碼。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-08"></a>

### E-08

原件 `sourceCode/AF/AFY10100.jsp:373–498`，上述 SHA-256；最小定位與事實：標題、查詢條件、條件式回檔選項與摘要。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-09"></a>

### E-09

原件 `sourceCode/AF/AFY10100.jsp:499–961`，上述 SHA-256；最小定位與事實：19 個保障項目、三組橫向區塊、千分位資料呈現。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-10"></a>

### E-10

原件 `sourceCode/AF/AFY10100.jsp:962–1094`，上述 SHA-256；最小定位與事實：三種保費彙整及操作者。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-11"></a>

### E-11

原件 `sourceCode/AF/AFY10100.jsp:1095–1708`，上述 SHA-256；最小定位與事實：隱藏編輯区、只讀鍵值、可輸入金額、人物資料與選項。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-12"></a>

### E-12

原件 `sourceCode/AF/AFY10100.jsp:1709–1785`，上述 SHA-256；最小定位與事實：18 欄明細標題與五個排序觸發。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-13"></a>

### E-13

原件 `sourceCode/AF/AFY10100.jsp:1786–1919`，上述 SHA-256；最小定位與事實：明細迭代、行內隱藏資料、單選、明細連結、數字格式。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-14"></a>

### E-14

原件 `sourceCode/AF/AFY10100.jsp:1920–1927`，上述 SHA-256；最小定位與事實：取回按鈕的允許旗標控制。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

<a id="e-15"></a>

### E-15

原件 `sourceCode/AF/AFY10100.jsp:1930–1994`，上述 SHA-256；最小定位與事實：八則說明與已記載彙整意圖。支撐同範圍前端可觀察／舊交接需求，不證明目標 API 承接或部署；來源非 legacy 執行觀察。

## 3. 來源覆蓋与符號映射

| 來源位置／符號 | 已知事實 | E | 契約／原型 | 案例／處理結論 |
| --- | --- | --- | --- | --- |
| L1–33 | 編碼、共用來源引入及全頁背景 | E-01 | FLOW-01/10；CMP-01 | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L35–91 | 標題定位、快捷鍵註冊、驗證規則及初始化順序 | E-02 | FLOW-01/10；CMP-01 | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L94–119 | 查詢、刪除、修改與取回的整份表單交接 | E-03 | FLOW-02/06/07；BOUND-01/03/04/05 | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L120–141 | 先驗證，再檢核識別值；Y 確認／取消及非 Y 分支 | E-04 | FLOW-03／BR-01–03 | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L144–226 | 選列逐欄回填、啟用三按鈕、顯示編輯區與造字呼叫 | E-05 | FLOW-04／DATA-09/10 | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L228–313 | 取消清空欄位、解除所有選取、禁用三按鈕並隱藏編輯區 | E-06 | FLOW-05 | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L315–369 | 明細參數、新視窗及無明示 URL 編碼 | E-07 | FLOW-08／BOUND-06 | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L373–498 | 標題、查詢條件、條件式回檔選項與摘要 | E-08 | SCR-01／UI 索引／DATA；SCR-01.html | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L499–961 | 19 個保障項目、三組橫向區塊、千分位資料呈現 | E-09 | SCR-01／UI 索引／DATA；SCR-01.html | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L962–1094 | 三種保費彙整及操作者 | E-10 | SCR-01／UI 索引／DATA；SCR-01.html | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L1095–1708 | 隱藏編輯区、只讀鍵值、可輸入金額、人物資料與選項 | E-11 | SCR-01／UI 索引／DATA；SCR-01.html | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L1709–1785 | 18 欄明細標題與五個排序觸發 | E-12 | SCR-01／UI 索引／DATA；SCR-01.html | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L1786–1919 | 明細迭代、行內隱藏資料、單選、明細連結、數字格式 | E-13 | SCR-01／UI 索引／DATA；SCR-01.html | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L1920–1927 | 取回按鈕的允許旗標控制 | E-14 | SCR-01／UI 索引／DATA；SCR-01.html | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |
| L1930–1994 | 八則說明與已記載彙整意圖 | E-15 | SCR-01／UI 索引／DATA；SCR-01.html | AC-01–16；來源明示已映射，依賴結果 TODO-01–05 |

本表分母是15個根頁來源區段，不含尚未取得的共用依賴內部；不能據此宣告入口整體全覆蓋。UI逐项原符号与行定位见 [ui-source-map.json](ui-source-map.json)，原型源模板没有稳定 id 的块按 E 区段回查。完整固定代码说明 L1936–1990 保留于原型，不推导成额外校验规则。

### 編輯与明細資料符號映射

| legacy symbol | 技術中立語意 | 回填／清空／傳遞 | 證據／限制 |
| --- | --- | --- | --- |
| TBL_NAME | 資料表識別 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| INSR_TYPE | 通報方式 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| CMNY_CODE | 公司別 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| I_ID | 被保人ID | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| I_BIRTHDAY | 被保人生日 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| POLICY_NO | 保單號碼 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| POLICY_CAT | 保單分類 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| POLICY_DUTY | 險種分類 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PROD_KIND | 險種 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| STATUS | 保單狀況 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| LST_CHG_DATE | 保單狀況生效日期(受理理賠日、身故日) | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| MAIN_POLICY_NO | 主約保單號碼 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| ISSUE_DATE | 契約生效日 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| ISSUE_TIME | 契約生效時分 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| LPS_DATE | 契約滿期日 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| LPS_TIME | 契約滿期時分 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| SIGN_DATE | 要保書填寫日 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PREM | 保費 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_FREQ | 保費繳別 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_PERIOD | 保費繳費年期 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| LST_CHG_TIME | 保單狀況生效時分 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| BROKTYPE | 保經代分類 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| A_NAME | 要保人姓名 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| A_ID | 要保人身分證號碼 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| A_BIRTHDAY | 要保人出生日期 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| RELATION | 要保人與被保險人關係 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| UPDATE_TIME | 資料寫入時間（送出值） | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| INPUT_TIME | 資料寫入時間（可見值） | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| SER_NO | 公會取回序號 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| I_GENDER | 被保人性別 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_TYPE | 公費自費 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| OIU_IND | 來源別代碼 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| SALE_CHNL | 銷售通路代碼 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PROD_CODE | 商品代碼 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| OIU_IND_DESC | 來源別說明 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| SALE_CHNL_DESC | 銷售通路說明 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| COMPANY_NAME | 公司名稱 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT1 | 身故 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT2 | 完全失能或最高級失能 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT3 | 失能扶助金 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT4 | 特定事故 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT5 | 初次罹患 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT6 | 醫療限額 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT7 | 醫療限額自負 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT8 | 醫療日額 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT9 | 住院手術 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT10 | 門診手術 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT11 | 門診 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT12 | 重大疾/傷病 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT13 | 重大燒燙傷 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT14 | 癌症療養 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT15 | 出院療養 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT16 | 喪失工作能力 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT17 | 喪葬費用 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT18 | 銜接原醫療限額之自負額 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |
| PAY_AMT19 | 分期給付 | selectItem／doCleanAll；openDetail 使用行原值（TBL_NAME/INPUT_TIME/說明值不在明細 URL） | E-05/06/07/11/13；DATA-09/10；TODO-01/04 |

### 交換原始符號（非目標 API）

| BOUND | legacy destination | 已知傳遞／回應消費 | 權威限制 |
| --- | --- | --- | --- |
| <a id="bound-01"></a>BOUND-01 | ${dispatcher}/AFY1_0100/doQuery | frm method=post；當前有 name 且成功控制項 | E-03/08；目標契約 TODO-04 |
| <a id="bound-02"></a>BOUND-02 | ${dispatcher}/AFY1_0100/doASyncCheckId | parameters.inputId；onSuccess(XHT,resp) 讀 resp.isIdError == Y | E-04；method/envelope/parse/error 依賴 TODO-03；目標 TODO-04 |
| <a id="bound-03"></a>BOUND-03 | ${dispatcher}/AFY1_0100/doASync | frm.submit()；送出當刻表單 | E-03/04；TODO-04 |
| <a id="bound-04"></a>BOUND-04 | ${dispatcher}/AFY1_0100/doEdit | 當前表單含編輯及隱藏選列值 | E-03/05/11；TODO-04 |
| <a id="bound-05"></a>BOUND-05 | ${dispatcher}/AFY1_0100/doDelete | 當前整份表單 | E-03；TODO-04 |
| <a id="bound-06"></a>BOUND-06 | dispatcher/AFY1_0100/doShowDetail | window.open(url)；各參數直接字串串接，未明示 encodeURIComponent | E-07；TODO-04 |

明細精確參數順序：`INSR_TYPE, CMNY_CODE, I_ID, I_BIRTHDAY, POLICY_NO, POLICY_CAT, POLICY_DUTY, PROD_KIND, STATUS, LST_CHG_DATE, MAIN_POLICY_NO, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, SIGN_DATE, PREM, PAY_FREQ, PAY_PERIOD, LST_CHG_TIME, PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, PAY_AMT18, PAY_AMT19, BROKTYPE, A_NAME, A_ID, A_BIRTHDAY, RELATION, UPDATE_TIME, SER_NO, I_GENDER, PAY_TYPE, OIU_IND, SALE_CHNL, PROD_CODE`。行內 hidden 沒有 name，不直接列入整份表單；selected hidden 有 name，取消清空後仍存在。checkbox 未勾選缺省，disabled button 不參與傳遞。已確認表單 method 不直接轉成目標 REST operation。

### LOGIC 混合責任盤點

| LOGIC | 觸發／原順序／副作用 | 責任 | 前端去向／承接 |
| --- | --- | --- | --- |
| LOGIC-01 | csCommon 情境→根頁條件／資料呈現 | 受信任情境与初始化外部資料；細節未取得 | DATA-02–10／BOUND-07；HANDOFF-01；TODO-01/04 |
| LOGIC-02 | fmt numeric→彙整與列顯示 | 資料呈現轉換；不是彙整運算 | DATA-06/07/08；TODO-04 精度／空值與算法 |
| LOGIC-03 | valid.validate→擷取識別值→Ajax→Y确认→當前整份表單取回 | 前端操作提示＋後端識別與取回責任 | FLOW-03；HANDOFF-02/03；TODO-03/04 |
| LOGIC-04 | 選列逐欄回填→enable→show→parseEUDC | 前端呈現／操作，造字語意待查 | FLOW-04；TODO-01 |
| LOGIC-05 | 取消逐欄清空→單選解除→disable→hide | 前端操作；不是取消後端請求 | FLOW-05；TODO-04 后端缺省接受 |
| LOGIC-06 | 查詢／修改／刪除送出 frm | 外部資料與業務副作用責任 | FLOW-02/06/07；HANDOFF-03/04；TODO-04 |
| LOGIC-07 | URL串接→window.open | 前端交接＋外部明細能力 | FLOW-08；HANDOFF-05；TODO-04 |
| LOGIC-08 | onload定位→註冊熱鍵→驗證→訊息；resize/scroll定位 | 前端生命週期；共用／全域部分待查 | FLOW-01/10；TODO-01/03/05 |
| LOGIC-09 | 標題箭頭→sortCol=-1→helper | 前端排序入口；比較與列處理未知 | FLOW-09；TODO-03 |
| LOGIC-10 | isAllow/isReturn 控制可見；role/status與性別費別回顯 | 呈現條件＋受信任設定 | BR-05／FLOW-11；HANDOFF-01；TODO-04 |

## 4. 缺口

<a id="todo-01"></a>

### TODO-01

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 依賴未建立／未知／未驗證；開啟，DEC-02已確認先翻新；已取得部分逐項保留证据，余缺口保持开啟 |
| 依賴 | DEP-01/02/09 |
| 具體問題 | header條件政策、訊息入口/完成/例外與MsgWin已建立消费契約。剩余缺口：csCommon/tag、parseEUDC实现、字型实体、WIUtil/底部框架运行映射、水印工具完整观察与受信任选用情境未确认。 |
| 已知證據 | E-01–15 的本頁使用位置，根頁已知反應仍保留；共用定義／目標權威未取得 |
| 影響 | FLOW-01/04/11、MSG-03、CMP-01及所有UI/ST，DATA-09。 |
| 下一步 | DEC-02已确认先翻新；已逐檔inventory并建立共用契約，下一步取得csCommon/tag、造字、字体／底部框架映射及水印实际情境。 |
| 解決條件 | 適用來源與版本、受影響契約更新、必要原型与介接驗證均有實際紀錄；不以文件生成關閉 |
| TASK／DEC／後續順序 | [plan](plan.md)：TASK-09及相關TASK-02–08；DEC-02先翻新共用，TASK-10明細內部已延後；TASK-08验证在資料取得後回查 |
| 解決紀錄 | 尚未解決 |

<a id="todo-02"></a>

### TODO-02

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 依賴未建立／未知／未驗證；開啟，DEC-02已確認先翻新；已取得部分逐項保留证据，余缺口保持开啟 |
| 依賴 | DEP-06/07 |
| 具體問題 | cssBase 候選映射与cm.css最終級聯、圖片未確認；原型僅用根頁明示屬性，不能宣告視覺等價。 |
| 已知證據 | E-01–15 的本頁使用位置，根頁已知反應仍保留；共用定義／目標權威未取得 |
| 影響 | CMP-01、全部UI／ST、FLOW-01/04/05/09/10。 |
| 下一步 | 決策後取得適用共用CSS与圖片，逐选择器／继承／状态回查 DESIGN/CSS/computed。 |
| 解決條件 | 適用來源與版本、受影響契約更新、必要原型与介接驗證均有實際紀錄；不以文件生成關閉 |
| TASK／DEC／後續順序 | [plan](plan.md)：TASK-09及相關TASK-02–08；DEC-02先翻新共用，TASK-10明細內部已延後；TASK-08验证在資料取得後回查 |
| 解決紀錄 | 尚未解決 |

<a id="todo-03"></a>

### TODO-03

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 依賴未建立／未知／未驗證；開啟，DEC-02已確認先翻新；已取得部分逐項保留证据，余缺口保持开啟 |
| 依賴 | DEP-03/04/05 |
| 具體問題 | Ajax method/解析/完成/例外、必要檢核兩模式、熱鍵与排序已取得来源与原型。date.js严格候选解码均失败，日期引入副作用、其他隐式共用运行资源与部署选用仍未确认。 |
| 已知證據 | E-01–15 的本頁使用位置，根頁已知反應仍保留；共用定義／目標權威未取得 |
| 影響 | FLOW-01/02/03/09/11、BR-01–03/06、MSG-01、DATA-01/11、ST-03/04。 |
| 下一步 | 決策後鎖版本與逐檔編碼，核對已知分支与失敗／空值／焦點／全頁事件。 |
| 解決條件 | 適用來源與版本、受影響契約更新、必要原型与介接驗證均有實際紀錄；不以文件生成關閉 |
| TASK／DEC／後續順序 | [plan](plan.md)：TASK-09及相關TASK-02–08；DEC-02先翻新共用，TASK-10明細內部已延後；TASK-08验证在資料取得後回查 |
| 解決紀錄 | 尚未解決 |

<a id="todo-04"></a>

### TODO-04

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 依賴未建立／未知／未驗證；開啟，DEC-02已確認先翻新；已取得部分逐項保留证据，余缺口保持开啟 |
| 依賴 | DEP-08/10 |
| 具體問題 | 後端基準未取得：入口資料、旗標、代碼說明、檢核、業務結果、取回／同步副作用、修改／刪除交易、明細目標映射未確認。 |
| 已知證據 | E-01–15 的本頁使用位置，根頁已知反應仍保留；共用定義／目標權威未取得 |
| 影響 | DATA-01–11、所有BOUND/ST、FLOW-01/02/03/05/06/07/08/11、BR-05、API索引及HANDOFF-01–05。 |
| 下一步 | 取得指定backend_root與同版本正式／設計契約，逐BOUND合法輸入、輸出与結果雙端核對；明細內部另scope。 |
| 解決條件 | 適用來源與版本、受影響契約更新、必要原型与介接驗證均有實際紀錄；不以文件生成關閉 |
| TASK／DEC／後續順序 | [plan](plan.md)：TASK-09及相關TASK-02–08；DEC-02先翻新共用，TASK-10明細內部已延後；TASK-08验证在資料取得後回查 |
| 解決紀錄 | 尚未解決 |

<a id="todo-05"></a>

### TODO-05

| 欄位 | 內容 |
| --- | --- |
| 類型／狀態 | 依賴未建立／未知／未驗證；開啟，未取得legacy執行環境 |
| 依賴 | 執行驗證 |
| 具體問題 | 未取得 legacy 真實執行畫面与資料，舊圖層分支／瀏覽器差異／正式服務介接未驗證；原型本地核對不能宣稱等價。 |
| 已知證據 | E-01–15 的本頁使用位置，根頁已知反應仍保留；共用定義／目標權威未取得 |
| 影響 | SCR-01、FLOW-01/08/10、ST與視覺樣式；AC-14–16及API驗證。 |
| 下一步 | 取得適用執行環境／資料，按AC观察真实初始化／几何／交接結果；不由存取限制推導未部署。 |
| 解決條件 | 適用來源與版本、受影響契約更新、必要原型与介接驗證均有實際紀錄；不以文件生成關閉 |
| TASK／DEC／後續順序 | [plan](plan.md)：TASK-09及相關TASK-02–08；DEC-02先翻新共用，TASK-10明細內部已延後；TASK-08验证在資料取得後回查 |
| 解決紀錄 | 尚未解決 |

## 5. 樣式与原型追蹤

CMP-01：[DESIGN](../../design/sourceCode-AF-AFY10100/components/CMP-01/DESIGN.md)、[CSS](../../design/sourceCode-AF-AFY10100/styles/CMP-01.css)、[prototype](../../design/sourceCode-AF-AFY10100/prototypes/SCR-01.html)、[tokens](../../design/sourceCode-AF-AFY10100/styles/tokens.json)。347 个明确声明映射在 [style-source-map.json](style-source-map.json)；每项原声明从root抽取至CSS，没有复制共用设计。表格原生width/height/cellspacing/cellpadding和font标记仍在HTML，动态top/display在JS；这些也属于呈现范围。

原型选列/取消代码来自E-05/06并仅替换造字调用为独立審阅层边界说明；其他本地脚本使用根頁可确认分支。共用库已获授权，已引用本地來源执行键盘、验证、排序、遮罩与訊息；所有旧服務停于審閱交接。复合请求的捕获值与回传顺序可由審阅层独立注入；不是正式请求。CSP阻断网络与表单提交。

## 6. 原有差異与改良提案

| 項目 | 原有事實／證據 | 候選改善（未批准） | 目前處理 |
| --- | --- | --- | --- |
| 顯示時間与提交時間不同 | UPDATE_TIME_text用INPUT_TIME；hidden UPDATE_TIME用UPDATE_TIME；E-05 | 确认产品是否应统一 | 保留差異；TODO-04 |
| 檢核值与取回值可不同 | 檢核捕获inputId；回應後重新提交當下frm；E-04 | 確認後端一致性保障 | 不加請求鎖或改成快照提交；TODO-04 |
| 重复HTML ID/結構 | rtnID/table_5與input-label多处重复、head未闭合、表单尾部顺序异常 | 未来實作整理结构 | 原型為可解析HTML对不参与行为的重复ID加後綴，保留data-source-id与可见结构；不改变业务需求 |
| 身故／醫療與金額字串 | 根頁可輸入任意文字，未設根頁數字檢核 | 後端驗證需契約確認 | 不擅自增加前端檢核；TODO-03/04 |

## 7. 驗證執行

實際結果待本輪核對後增補；案例定義不等同通過。

## 8. 變更紀錄

CHANGE-01／2026-10-12：初次建立 scope；plan先于来源读取；DEC-01 auto=all；所有E新增；DEC-02待决；原件未修改。产物SHA-256见本轮验证后建立的artifact-manifest.json。

## 9. 共用依賴增補證據與版本

<a id="e-16"></a>

### E-16

`sourceCode/CM/header.jsp:20–413`，SHA-256 `60508a333aa5411f59f252489e4ec50746a8ff84103c0083d777ec1b7283d44d`；413原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。受信任情境tag、功能政策、全頁capture事件、复制去重与独立60秒计时、服务端水印资料、字型與生命周期；watermark berforeunload原拼字及handler差異保留。 不證明實际部署映射或目標後端。

<a id="e-17"></a>

### E-17

`sourceCode/CM/msgDisplayer.jsp:1–188`，SHA-256 `e39c5526a4ee108bcd8561716ca1e25324e8ad12e3743b13681193c42c9a1ec6`；188原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。ReturnMessage正規化、底部frame順序、回滾早退、全部警示组裝、WIUtil+jQuery/原生分支、document button/submit click清除。 不證明實际部署映射或目標後端。

<a id="e-18"></a>

### E-18

`sourceCode/CM/js/ajax/prototype.js:1728–2088`，SHA-256 `f727ce3e418c76558c3882064c7b0b4743cd1bcef0e25ebd19d807ad47850636`；7745原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。请求默认post/asynchronous/form-urlencoded UTF-8、onCreate、先成功/失败再Complete/Responder、JSON媒体型別与空值解析、onException。 不證明實际部署映射或目標後端。

<a id="e-19"></a>

### E-19

`sourceCode/CM/js/ajax/CSRUtil.js:371–757`，SHA-256 `d71734e1cd4ec8cd978020cc670101de9b86ff70a96c0daf4c8d875d065a28e6`；2638原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。default responders onCreate/Complete/Exception与条件错误/成功呈现、超时仅有指定时、getMsgBoard；根页是Ajax.Request而非另一jQuery post包装。 不證明實际部署映射或目標後端。

<a id="e-20"></a>

### E-20

`sourceCode/CM/js/ui/validation.js:87–842`，SHA-256 `c1863e185750008ec18f83b97e7d29386dfec286e95d2c51062ccfbd1d090839`；967原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。默认选模式、按class及多重规则顺序、required null/零长度而非trim、advice与聚合alert、焦点次序、计数移除与错误残留。 不證明實际部署映射或目標後端。

<a id="e-21"></a>

### E-21

`sourceCode/CM/js/ajax/CSRUtil.js:154–335`，SHA-256 `d71734e1cd4ec8cd978020cc670101de9b86ff70a96c0daf4c8d875d065a28e6`；2638原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。遮罩创建／取得、位置与尺寸、每次show/hide及窗口focus；MsgWin另见同源L1420–1696（已核对physical lines）。 不證明實际部署映射或目標後端。

<a id="e-22"></a>

### E-22

`sourceCode/CM/js/HotKey.js:20–107`，SHA-256 `7501d3cdd52084dec29be7a18b6b5b232de4fa11447c7a7742a4f7f12b94576d`；107原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。document.onkeydown、Alt/Ctrl/Shift优先、button.click、缺按钮不设execute、returnValue=false。 不證明實际部署映射或目標後端。

<a id="e-23"></a>

### E-23

`sourceCode/CM/css/cm.css:1–957`，SHA-256 `92b0ad8c25e35c47d46e6f79391803f5f414046faa731712aa7f8478bfee535f`；957原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。实际完整候选CSS文本、來源順序、:root較高權重padding、表格/文字/disabled与body规则；仅匹配本頁subset投影。 不證明實际部署映射或目標後端。

<a id="e-24"></a>

### E-24

`sourceCode/CM/js/sortControler_ac.js:1–221`，SHA-256 `04470ef6c2d3b7ad36bb48e3b51b826ae68b6926ea5f090e852f32d720fdabfd`；363原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。本頁sortTable使用大寫innerHTML字串、方向0升序、少于2行、cloneNode→插入→刪舊行、交錯行底色、不重編序號。 不證明實际部署映射或目標後端。

<a id="e-25"></a>

### E-25

`sourceCode/CM/js/calendar.js:1–1430`，SHA-256 `f39aadb9e108b0aea6ccf6f192cd601c0bc7eed1ea80a4ec7aee8faf1149d778`；1430原始物理行；inventory嚴格候選与行尾在 [dependency-inventory](dependency-inventory.json)。分析副本選用cp950并核对可读中文字义，原件未修改。取得可嚴格解碼的日曆来源；只核對頂層與引入；根頁未見日期触发，不宣告date.js副作用不存在。 不證明實际部署映射或目標後端。

### 依賴實際停止邊界

| DEP | 讀取／停止 | 消費契約與缺口 |
| --- | --- | --- |
| DEP-01/02/09 | header L1–413；msgDisplayer L1–188；tag/造字实现未取得 | shared-contract FLOW-13/16；TODO-01/04 |
| DEP-03 | Prototype请求L1728–2088；CSR相关helper/responder/UI core/MsgWin L1–35、154–335、371–757、1420–1696、2509–2638 | FLOW-12/14/15；其他模块完整生成不纳入；TODO-01/02/04 |
| DEP-04 | HotKey20–107；validation默认/两mode/multi/required相关87–842；sortTable1–221 | FLOW-17/18；不对其他校验器/排序函数创建根页要求 |
| DEP-05 | calendar顶层变量与结尾，无根页调用；date.js严格解码失败 | TODO-03；没有替换解码 |
| DEP-06/07 | cm.css完整957行读入、匹配rule按来源順序投影；图片未找到 | CMP-02；实际cssBase及bt_bg/cover/loading/frame/icon资源TODO-02 |
| DEP-09/11 | watermark1272行metadata与初始化候选、utility1351行只扫描符号與调用链（未证明由tag引入）；msgBox/msgBoard候选不等同MsgWin | 已有header调用契约；不是运行绑定证据；TODO-01 |
| DEP-12 | bottom_css L57–91及bottom/sys_menu只搜索show/clear候选；分别inventory | 具體候選不同，不自动選定部署；TODO-01 |
| DEP-08/10 | 未取得後端产物；明细内部用户明确延后 | API/HANDOFF缺口与TODO-04；明細另scope |


### 共用來源覆蓋

| 來源／分支 | 契約 | 原型／案例 | 處理 |
| --- | --- | --- | --- |
| E-16 PD_CTRL真/假、全頁事件、打印 | CMP-04/FLOW-16/ST政策条件 | header-policy.js；AC-22/23 | 已描述條件；選用情境TODO-04 |
| E-16 copies空/重複/新/長度/计时交错 | FLOW-16/BOUND-08 | AC-23；审閱交接停止 | 稽核HANDOFF-06，TODO-04 |
| E-16水印/字符byte/情境参数及工具可存在/否 | FLOW-16/初始化资料 | 水印仅契约，字型与工具完整QA未执行 | TODO-01/04/05 |
| E-17入口码0/99/其他、例外、底部、回滚、工具条件、click清除 | FLOW-13/MSG-03 | AC-24；原型未提供运行frame | 已契約，TODO-01/05 |
| E-18/19请求create/success/failure/complete/exception/timeout | FLOW-12/ST-03/06/BOUND-02 | legacy-common.js／合成response；AC-18/25 | 原型保留已知本地生命周期；完整输送未驗證TODO-04 |
| E-21 message空/重复/新/尺寸/keypress/close/reopen/drag | FLOW-14/15/ST-07/08/UI-202–206 | 原生来源组件；AC-19–21 | 可本地驗證；图像TODO-02 |
| E-20必要空/纯空格、default/DS模式、advice计数、焦点顺序 | FLOW-17/BR-01/MSG-01 | legacy-validation.js；AC-17 | 可本地驗證；部署选用仍待确认 |
| E-22有/缺按钮、disabled、修飾優先 | FLOW-17/快捷鍵 | legacy-hotkey.js；AC-14 | 可本地驗證 |
| E-24方向、字符串、0/1行、clone、颜色、index | FLOW-18/FLOW-09/TR-12/13 | legacy-sort.js；AC-12 | 可本地驗證 |
| E-23继承/root权重/disabled/输入/表格 | CMP-02全部UI | CMP-02.css；computed核对 | 候選映射TODO-02 |
| date.js双候选解码失败 | 引入未知契约 | 未进入原型；TODO-03 | 阻塞不宣称完整 |


CHANGE-02／2026-10-13：DEC-02沿用用户明確回覆；新增E-16–25，共用FLOW-12–18与CMP-02–04；明細内部联系延後。原型升级本地必要检核、熱鍵、排序、请求遮罩、訊息与政策条件；copy记录／服务仍停在边界。新增DEP-11/12支援原已授权header/讯息的有限查证，未新增第二根入口。

## 10. 已執行驗證（2026-10-13）

| V | 依據／環境／實際操作 | 實際結果與紀錄 | 判定／限制 |
| --- | --- | --- | --- |
| V-01 | source_inventory逐檔嚴格候選、raw bytes雜湊与line基准；原件回讀 | 入口2013行；每個依賴metadata獨立保存；date.js兩候選失敗；所有鎖定來源雜湊一致 | metadata通過；date編碼TODO-03 |
| V-02 | 靜態文件/連結/引用/JS/JSON、root樣式來源映射、所用DTCG格式 | [static-verification.json](static-verification.json)：703 Markdown文件/anchor連結、347 root樣式宣告、4 tokens、9腳本語法，無錯誤 | 通過所查範圍；不是完整官方標準validator或像素验证 |
| V-03 | PyYAML元件profile形狀檢查；CMP-01–04 | [design-metadata-check.json](design-metadata-check.json) PASS；只检查frontmatter名稱、群組及typography欄位 | 通過有限metadata範圍 |
| V-04 | 本機Chrome 1280×720，http://127.0.0.1:8765/prototypes/SCR-01.html；合成兩列，實際點擊/鍵盤/拖曳與computed style | [browser-results.json](browser-results.json)：33個檢查全部PASS；含選列/重選/取消、全表單交接、明細原列、五欄兩方向與行序、空/純空白、確認/取消、請求2先於1、遮罩活動數、F2/禁用F9、MsgWin去重/上限/null/一次性keypress/重開/拖曳；pageerror為空 | 本機原型通過；正式API、legacy运行/字型/圖片未验证 |
| V-05 | 本機合成policy=Y與subsystem=DS，實際鍵盤與print媒體；browser clock控制t0/A→t30/B→t59/B→t61/B | [policy-results.json](policy-results.json)：7檢查全部PASS；capture阻止Ctrl+A、print隱藏body與警語、t59重複不交接、t60較早timer清空、t61B再次交接、DS聚合檢核原文 | 本機條件分支與虛擬時計時序通過；不是已確認現行政策或真實稽核 |

### 視覺紀錄

[ST-01取消後畫面](../../../output/playwright/AFY10100-initial.png)與[ST-02選列畫面](../../../output/playwright/AFY10100-selected.png)已實際截圖並視覺檢查。截圖是驗證序列後狀態：識別值DEMO-HOTKEY、同步勾選保留、結果列經降序排序；不是原系統初次載入影像。無遮擋產品操作，表格結構与已知狀態可核對；全頁原生表格未新增responsive產品規則。審閱工具260px左列置於產品之後，與來源中央訊息視窗分開；未使用force click。

### 驗證修正及保留限制

初次排序因HTML序列化把JavaScript URL空白編成%20而無效，改同參數onclick與return false，五欄已重測通過。初次審閱區覆蓋訊息確定，調整審閱工具寬度而保留產品幾何／層級後重測通過。一次性keypress案例原預期忽略了確定按鈕原生Enter點擊，改為先移焦至審閱文字欄再驗證監聽解除；按鈕焦點下Enter可關閉的觀察也保留。政策觀察器原放bubble而被capture阻斷，改同capture觀察後證實預設動作已阻止。

Browser連線初次無可用實例，CLI網路套件查找失敗；後使用本機快取與本地靜態伺服器完成瀏覽器核對。未使用他人登入資料、外部業務服務或正式資料。可重現案例腳本存於[verification](verification/browser-cases.js)，需實際Playwright page與本機原型；確認對話會讓CLI先返回，最終JSON是在瀏覽器狀態逐筆保存後另行讀取，不能將CLI exit=0視作全部通過。

### 本輪交付判定

**部分交付**：所有可取得的根頁及共用來源消费契約已整理，已選任務的已知部分有本地原型、樣式與驗證。TODO-01實體tag/造字/字型/工具与部署映射、TODO-02實际cssBase/圖片、TODO-03日期編碼/引入副作用、TODO-04目標後端承接／明細內部延後、TODO-05legacy真實環境及正式介接仍未解。不能由本機合成案例或產物齊備宣告完整入口／像素等價／正式API可用。

| V | 依據／操作與環境 | 實際結果 | 判定／限制 |
| --- | --- | --- | --- |
| V-06 | 本機Chrome合成入口碼0/99/錯誤/例外、自訂工具存在、底部frame回滾／顯示／按鈕清除，DS自訂錯誤、EP成功、非JSON文字与診斷 | [message-results.json](message-results.json)：11檢查全部PASS；底部frame与工具是測試中建立的替身，完成後移除；未連服務 | 已取得共用客戶端分支通過；不能證明正式框架／WIUtil或目標回應契約 |

FLOW-03不先檢查業務返回碼是否成功：根頁在傳輸成功回呼只讀識別旗標；其後才執行共用完成階段的業務錯誤訊息。來源E-04/18/19；不能把CSRUtil.isSuccess套進根頁流程改為新guard。

STYLE-C-CONFIRM：來源確定按鈕inline padding 0 15px外置為CMP-03.css的`:root .button.common-confirm`，保留高於候選:root .button（左右10px）的優先序。STYLE-C-COVER：共用遮罩的靜態100%寬高、left/top0、padding0、margin0 auto外置為`.common-cover`；fixed/absolute分支、zIndex參數及顯示／只增高度仍由來源公式維護。

## 11. 實際缺口位置回讀核對

此表由回讀已交付契約中的實際TODO行／段落建立，包含DATA／ST／UI、共同使用位置与FLOW。連結指向實際ID錨點（若該段沒有單独錨點则文件加章節名稱），不能代表未知依赖已完整盘点。共同樣式／政策按CMP继承影响全部UI；本頁受信任数据与service结果按实际DATA/BOUND引用回查。

| TODO | 實際受影響位置 | 定位連結 | TASK／DEC | 回讀結果 |
| --- | --- | --- | --- | --- |
| TODO-01 | specification.md／1. 範圍、角色與意圖／1. 範圍、角色與意圖 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／1. 範圍、角色與意圖／1. 範圍、角色與意圖 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／1. 範圍、角色與意圖／1. 範圍、角色與意圖 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／2. 資料語意／DATA-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-01)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／2. 資料語意／DATA-02 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-02)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／2. 資料語意／DATA-03 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-03)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／2. 資料語意／DATA-04 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-04)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／2. 資料語意／DATA-05 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-05)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／2. 資料語意／DATA-06 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-06)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／2. 資料語意／DATA-07 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-07)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／2. 資料語意／DATA-08 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-08)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／2. 資料語意／DATA-09 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-09)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／2. 資料語意／DATA-10 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-10)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／2. 資料語意／DATA-11 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-11)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／保障項目與資料範圍／保障項目與資料範圍 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／3. 畫面與元件／CMP-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#cmp-01)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／3. 畫面與元件／CMP-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#cmp-01)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／3. 畫面與元件／3. 畫面與元件 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／可見元素索引／可見元素索引 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／可見元素索引 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-001 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-001)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-002 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-002)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-003 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-003)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-004 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-004)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-005 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-005)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-006 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-006)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-007 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-007)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-008 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-008)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-009 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-009)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-010 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-010)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-011 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-011)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-012 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-012)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-013 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-013)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-014 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-014)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-015 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-015)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-016 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-016)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-017 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-017)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-018 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-018)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-019 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-019)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-020 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-020)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-021 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-021)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-022 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-022)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-023 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-023)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-024 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-024)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-025 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-025)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-026 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-026)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-027 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-027)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-028 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-028)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-029 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-029)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-030 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-030)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-031 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-031)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-032 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-032)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-033 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-033)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-034 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-034)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-035 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-035)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-036 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-036)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-037 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-037)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-038 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-038)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-039 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-039)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-040 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-040)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-041 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-041)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-042 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-042)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-043 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-043)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-044 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-044)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-045 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-045)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-046 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-046)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-047 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-047)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-048 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-048)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-049 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-049)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-050 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-050)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-051 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-051)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-052 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-052)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-053 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-053)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-054 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-054)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-055 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-055)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-056 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-056)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-057 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-057)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-058 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-058)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-059 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-059)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-060 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-060)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-061 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-061)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-062 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-062)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-063 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-063)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-064 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-064)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-065 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-065)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-066 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-066)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-067 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-067)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-068 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-068)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-069 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-069)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-070 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-070)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-071 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-071)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-072 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-072)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-073 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-073)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-074 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-074)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-075 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-075)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-076 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-076)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-077 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-077)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-078 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-078)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-079 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-079)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-080 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-080)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-081 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-081)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-082 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-082)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-083 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-083)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-084 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-084)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-085 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-085)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-086 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-086)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-087 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-087)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-088 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-088)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-089 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-089)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-090 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-090)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-091 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-091)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-092 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-092)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-093 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-093)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-094 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-094)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-095 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-095)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-096 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-096)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-097 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-097)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-098 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-098)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-099 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-099)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-100 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-100)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-101 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-101)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-102 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-102)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-103 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-103)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-104 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-104)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-105 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-105)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-106 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-106)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-107 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-107)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-108 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-108)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-109 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-109)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-110 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-110)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-111 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-111)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-112 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-112)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-113 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-113)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-114 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-114)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-115 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-115)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-116 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-116)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-117 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-117)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-118 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-118)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-119 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-119)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-120 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-120)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-121 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-121)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-122 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-122)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-123 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-123)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-124 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-124)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-125 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-125)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-126 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-126)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-127 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-127)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-128 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-128)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-129 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-129)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-130 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-130)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-131 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-131)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-132 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-132)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-133 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-133)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-134 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-134)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-135 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-135)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-136 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-136)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-137 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-137)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-138 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-138)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-139 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-139)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-140 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-140)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-141 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-141)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-142 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-142)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-143 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-143)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-144 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-144)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-145 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-145)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-146 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-146)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-147 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-147)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-148 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-148)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-149 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-149)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-150 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-150)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-151 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-151)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-152 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-152)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-153 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-153)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-154 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-154)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-155 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-155)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-156 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-156)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-157 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-157)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-158 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-158)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-159 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-159)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-160 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-160)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-161 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-161)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-162 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-162)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-163 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-163)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-164 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-164)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-165 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-165)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-166 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-166)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-167 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-167)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-168 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-168)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-169 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-169)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-170 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-170)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-171 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-171)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-172 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-172)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-173 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-173)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-174 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-174)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-175 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-175)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-176 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-176)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-177 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-177)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-178 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-178)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-179 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-179)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-180 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-180)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-181 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-181)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-182 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-182)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-183 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-183)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-184 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-184)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-185 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-185)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-186 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-186)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-187 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-187)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-188 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-188)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-189 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-189)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-190 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-190)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-191 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-191)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-192 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-192)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-193 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-193)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-194 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-194)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-195 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-195)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-196 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-196)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-197 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-197)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-198 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-198)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／可見元素索引／UI-199 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#ui-199)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／編輯資料／編輯資料 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／編輯資料／編輯資料 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／編輯資料／編輯資料 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／4. 狀態與轉移／ST-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#st-01)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／4. 狀態與轉移／ST-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#st-01)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／4. 狀態與轉移／ST-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#st-01)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／4. 狀態與轉移／ST-02 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#st-02)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／4. 狀態與轉移／ST-02 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#st-02)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／4. 狀態與轉移／ST-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#st-01)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／4. 狀態與轉移／ST-03 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#st-03)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／4. 狀態與轉移／ST-04 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#st-04)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／4. 狀態與轉移／ST-05 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#st-05)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／5. 規則與訊息／BR-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#br-01)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／5. 規則與訊息／MSG-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#msg-01)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／5. 規則與訊息／BR-02 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#br-02)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／5. 規則與訊息／MSG-02 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#msg-02)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／5. 規則與訊息／BR-03 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#br-03)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／5. 規則與訊息／BR-04 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#br-04)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／5. 規則與訊息／BR-05 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#br-05)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／5. 規則與訊息／BR-06 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#br-06)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／5. 規則與訊息／MSG-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#msg-01)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／5. 規則與訊息／MSG-03 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#msg-03)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／FLOW-01：入口初始化／FLOW-01：入口初始化 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-01)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／FLOW-01：入口初始化／FLOW-01：入口初始化 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-01)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／FLOW-01：入口初始化／FLOW-01：入口初始化 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-01)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／FLOW-01：入口初始化／FLOW-01：入口初始化 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-01)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-05 | specification.md／FLOW-01：入口初始化／FLOW-01：入口初始化 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-01)；[缺口詳情](#todo-05) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／FLOW-02：查詢交接／FLOW-02：查詢交接 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-02)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／FLOW-02：查詢交接／FLOW-02：查詢交接 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-02)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／FLOW-03：取回前識別檢核及回應／FLOW-03：取回前識別檢核及回應 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-03)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／FLOW-03：取回前識別檢核及回應／FLOW-03：取回前識別檢核及回應 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-03)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／FLOW-04：選列回填／FLOW-04：選列回填 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-04)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／FLOW-04：選列回填／FLOW-04：選列回填 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-04)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／FLOW-05：取消編輯／FLOW-05：取消編輯 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-05)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／FLOW-05：取消編輯／FLOW-05：取消編輯 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-05)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／FLOW-06：修改交接／FLOW-06：修改交接 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-06)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／FLOW-07：刪除交接／FLOW-07：刪除交接 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-07)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／FLOW-08：明細交接／FLOW-08：明細交接 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-08)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-05 | specification.md／FLOW-08：明細交接／FLOW-08：明細交接 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-08)；[缺口詳情](#todo-05) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／FLOW-09：排序觸發／FLOW-09：排序觸發 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-09)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／FLOW-09：排序觸發／FLOW-09：排序觸發 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-09)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／FLOW-10：標題重新定位／FLOW-10：標題重新定位 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-10)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-05 | specification.md／FLOW-10：標題重新定位／FLOW-10：標題重新定位 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-10)；[缺口詳情](#todo-05) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／FLOW-11：輸入及條件操作／FLOW-11：輸入及條件操作 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-11)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／FLOW-11：輸入及條件操作／FLOW-11：輸入及條件操作 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-11)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／FLOW-11：輸入及條件操作／FLOW-11：輸入及條件操作 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-11)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／BOUND-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#bound-01)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／DATA-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-01)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／FLOW-02 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-02)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／BOUND-02 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#bound-02)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／DATA-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-01)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／DATA-11 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-11)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／FLOW-03 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-03)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／BOUND-03 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#bound-03)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／FLOW-03 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-03)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／BOUND-04 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#bound-04)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／FLOW-06 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-06)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／BOUND-05 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#bound-05)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／FLOW-07 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-07)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／BOUND-06 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#bound-06)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／FLOW-08 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-08)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／BOUND-07 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#bound-07)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／DATA-02 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#data-02)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／7. 邊界及後端責任／FLOW-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-01)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／8. 行為驗收案例定義／8. 行為驗收案例定義 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／8. 行為驗收案例定義／8. 行為驗收案例定義 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／8. 行為驗收案例定義／8. 行為驗收案例定義 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／8. 行為驗收案例定義／8. 行為驗收案例定義 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／8. 行為驗收案例定義／8. 行為驗收案例定義 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-05 | specification.md／8. 行為驗收案例定義／FLOW-10 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#flow-10)；[缺口詳情](#todo-05) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／9. 原型與樣式索引／CMP-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#cmp-01)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／9. 原型與樣式索引／CMP-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#cmp-01)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／9. 原型與樣式索引／CMP-01 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#cmp-01)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-05 | specification.md／9. 原型與樣式索引／9. 原型與樣式索引 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-05) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／10. 共用契約引用与補充狀態／CMP-02 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#cmp-02)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／10. 共用契約引用与補充狀態／CMP-03 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#cmp-03)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／10. 共用契約引用与補充狀態／CMP-04 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md#cmp-04)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | specification.md／10. 共用契約引用与補充狀態／10. 共用契約引用与補充狀態 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | specification.md／10. 共用契約引用与補充狀態／10. 共用契約引用与補充狀態 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | specification.md／10. 共用契約引用与補充狀態／10. 共用契約引用与補充狀態 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／10. 共用契約引用与補充狀態／10. 共用契約引用与補充狀態 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-05 | specification.md／10. 共用契約引用与補充狀態／10. 共用契約引用与補充狀態 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-05) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | specification.md／10. 共用契約引用与補充狀態／10. 共用契約引用与補充狀態 | [契約位置](../../design/sourceCode-AF-AFY10100/specification.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | shared-contract.md／CMP-02：共用頁面呈現（候選版本）／CMP-02：共用頁面呈現（候選版本） | [契約位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#cmp-02)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-02 | shared-contract.md／FLOW-12：請求建立／完成／例外／FLOW-12：請求建立／完成／例外 | [契約位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#flow-12)；[缺口詳情](#todo-02) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | shared-contract.md／FLOW-12：請求建立／完成／例外／FLOW-12：請求建立／完成／例外 | [契約位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#flow-12)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | shared-contract.md／FLOW-13：入口訊息与任意按鈕清除／FLOW-13：入口訊息与任意按鈕清除 | [契約位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#flow-13)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | shared-contract.md／FLOW-16：條件政策／FLOW-16：條件政策 | [契約位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#flow-16)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | shared-contract.md／FLOW-16：條件政策／BOUND-08 | [契約位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#flow-16)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-01 | shared-contract.md／FLOW-16：條件政策／FLOW-16：條件政策 | [契約位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#flow-16)；[缺口詳情](#todo-01) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-03 | shared-contract.md／FLOW-18：排序與日期引入／FLOW-18：排序與日期引入 | [契約位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#flow-18)；[缺口詳情](#todo-03) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |
| TODO-04 | shared-contract.md／驗收案例／驗收案例 | [契約位置](../../design/sourceCode-AF-AFY10100/shared-contract.md)；[缺口詳情](#todo-04) | TASK-02–09／DEC-02先翻新；明細TASK-10延後 | 實際行／段落存在；V-07 |

元件DESIGN局部TODO同样逐檔回讀，CMP-01–04与实际CSS/prototype索引存在；样式本身未知处留TODO而不补值。已知后端需求在api-spec及backend-handoff各位置均保留TODO-04。

V-07／2026-10-13：回讀329個實際缺口位置（含UI、DATA、ST、FLOW與共用定義）；對應plan TASK／DEC與既有TODO詳情存在。這是局部缺口標示核對，不宣告未知依賴覆蓋完成。

V-08／2026-10-13：[metadata-browser-result.json](metadata-browser-result.json)實測遮罩ST-03→ST-06、訊息ST-07、確定UI-205、拖曳ST-08、關閉ST-06，全部符合；檢查最後追蹤屬性調整，未更動產品流程。

<a id="e-26"></a>

### E-26

`sourceCode/CM/js/ui/watermark-js-plus.js:316–357, 906–1114`；版本1.6.0；SHA-256 `91a39b227521f51d160a245d8ba05731908e58b63f58c01e164b944793dddea6`；1272物理行，cp950嚴格可讀。根multi-line-text/grid配置、root DOM、背景尺寸、create/remove與自己/parent MutationObserver；非其他image/blind模式消费契约。来源脚本保持本地，僅加UI/CMP/ST metadata于observer建立之前，避免metadata改动触发重建；原頭部条件身份/时间/旗标不替代真实後端。

## 12. 最終增補與剩餘限制

DATA-12／DATA-13新增於根頁資料語意位置，各有TODO-01/04直接連結；共同情境、訊息原始物件与目标API未取得權威，不由字段名称補造傳輸schema。CMP-05／ST-09／UI-207已補原型的條件水印示例，文字與時間合成；來源watermark外層root盒高為0，可見內容在fixed內層，UI-ID因此掛在實際可見層，不改原有幾何。初次驗證等外層visible超時是測試定位問題，改檢查fixed可見層後重驗。

| TODO | 新增實際位置 | 契約位置 | TASK／DEC | 回讀結果 |
| --- | --- | --- | --- | --- |
| TODO-01 | DATA-12受信任情境 | [位置](../../design/sourceCode-AF-AFY10100/specification.md#data-12) | TASK-02/09／DEC-02 | 直接TODO連結存在 |
| TODO-04 | DATA-12受信任情境 | [位置](../../design/sourceCode-AF-AFY10100/specification.md#data-12) | TASK-05/06/09／DEC-02 | 直接TODO連結存在 |
| TODO-01 | DATA-13訊息物件 | [位置](../../design/sourceCode-AF-AFY10100/specification.md#data-13) | TASK-02/09／DEC-02 | 直接TODO連結存在 |
| TODO-04 | DATA-13訊息物件 | [位置](../../design/sourceCode-AF-AFY10100/specification.md#data-13) | TASK-05/06/09／DEC-02 | 直接TODO連結存在 |
| TODO-01 | CMP-05共用水印 | [位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#cmp-05) | TASK-03/04/09／DEC-02 | 直接TODO連結存在 |
| TODO-04 | CMP-05水印情境 | [位置](../../design/sourceCode-AF-AFY10100/shared-contract.md#cmp-05) | TASK-05/06/09／DEC-02 | 直接TODO連結存在 |
| TODO-01/04/05 | ST-09水印已建立 | [位置](../../design/sourceCode-AF-AFY10100/specification.md#st-09) | TASK-03/08/09／DEC-02 | 直接TODO連結存在 |

CHANGE-04／2026-10-13：沿用已授權TASK-09，補齊已取得水印工具的條件prototype與CMP-05樣式；新增E-26、DATA-12/13、ST-09／UI-207與AC-26。非根入口的新範圍未擴張。

V-09／2026-10-13：[watermark-browser-result.json](watermark-browser-result.json)PASS。Chrome合成watermark=Y，實際fixed可見層pointer-events:none、zIndex2147483647、背景data URL、344px154px；查詢按鈕可點且BOUND-01；移除來源水印wrapper後重建1份。已截圖並視覺檢查[合成水印畫面](../../../output/playwright/AFY10100-watermark.png)。範圍是本頁root模式与所用grid；跨frame、舊事件分支与真實身份／字型不在此驗證結果。

最終本機紀錄：33個根頁/訊息/樣式操作、7個政策/計时/DS操作、11個訊息分支檢查皆PASS；另有metadata与條件水印核對PASS。最終靜態結果以static-verification.json為準，後續新增連結与CMP-05已重新核對；不是正式環境或完整來源覆蓋率。
