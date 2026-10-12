# v3 冷啟動差異分析

> 分析日期：2026-09-22  
> 分析角色：依 `docs/protocol.md` 的 v3 冷啟動分析者  
> 讀取範圍：根 `README.md`、`docs/protocol.md`、`docs/v1/samples.md`（只取固定樣本資訊與路徑）、`docs/v3/template.md`、`docs/v3/rules.md`、三個基準 JSP、三份畫面 SoT、`docs/v3/sot/SHARED-CM-includes.md`。  
> 未讀：`docs/v1/analysis.md`、`docs/v2/analysis.md`、前輪 SoT、具體遺漏清單、Git history、三個樣本以外的原始碼。共用 include 的原始 JSP 不在本分析者可讀清單，因此共用 SoT 僅做文件內部與跨文件一致性核對，不宣稱重新覆核其原始碼。

## 1. 結論與統計

v3 尚未收斂。畫面行為、服務、狀態與缺陷記錄已相當完整，但仍有 **19 項**可執行的缺口或過度記錄，其中 **7 項**有直接的反向重建行為差異風險。主要瓶頸已從一般程式邏輯轉為兩類：

1. AFY10100 的高密度視覺語意被壓成摘要，欄位—標籤—位置—排序的關係無法只靠目前 Markdown 重建。
2. 文件雖附機械檢查清單，仍有錯誤的表格欄數、錯誤的 null 輸出、錯誤的固定樣本層級與自相矛盾的 `[DEAD-CODE]` 標註。

| 指標 | v3 結果 | 口徑 |
|---|---:|---|
| `N_total` | **19** | 以下每個 `V3-xx` 為一項；重複族群（例如 19 個欄位映射）合併成一項，避免以出現次數灌大 |
| `N_high` | **7** | 僅計「只照 SoT 重建，有直接可信路徑產生可觀察行為、資源載入或版面差異」 |
| `N_new` | **待主線與前輪比較** | 本分析者依協定未讀前輪具體清單；候選新類型是「雙產物之間的視覺／行為連結完整性」與「自我稽核宣告本身的可驗證性」 |

分文件計數：

| 文件 | 項數 | High | 主要類型 |
|---|---:|---:|---|
| `DSC80106.md` | 3 | 2 | GAP-1、GAP-6、OVER |
| `DSC32200.md` | 2 | 0 | GAP-6、OVER |
| `AFY10100.md` | 8 | 5 | GAP-2、GAP-5、GAP-6、GAP-7、OVER |
| `SHARED-CM-includes.md` | 4 | 0 | GAP-6、OVER |
| 跨文件 | 2 | 0 | GAP-9、OVER-1 |

## 2. 機械計數與行為事實抽樣

### 2.1 重新計數結果

| 樣本 | 實際行數 | `<%= %>` | `${...}` 出現位置 | 外部 script | 靜態表單控制項 | 其他機械結果 |
|---|---:|---:|---:|---:|---:|---|
| DSC80106 | 241（`wc -l=240`，末行無換行） | 6 | 4 | 4 | 1 | 23 個資料 `div`、26 個靜態 id、1 個 Ajax |
| DSC32200 | 384（`wc -l=383`，末行無換行） | 12 | 12 | 9 | 6 | 9 個靜態 id、1 個 Ajax、2 個 popup 目標 |
| AFY10100 | 2013 | 19 | 240（163 種） | 7 | 108 input + 4 select + 4 button | 12 個 `c:if`、1 個 `c:forEach`、88 個 `fmt:formatNumber`、58 個 `${status.index}`、57 個無 name input |

上述主要計數與三份 SoT 的自報值一致。例外不是總數，而是語意：AFY 的保障表每一個資料列實際都是 **15 個 `<td>`**，不是 SoT 所稱「部分來源列超過 16 格」。重跑方式：

```bash
iconv -f BIG5 -t UTF-8 sourceCode/AF/AFY10100.jsp \
  | sed -n '499,958p' \
  | awk 'BEGIN{RS="</tr>"} {n=gsub(/<[tT][dD][ >]/,"&"); if(n) print NR,n}'
# 1, 15, 15, 15, 15, 15, 15, 15, 15
```

### 2.2 每檔至少五個具行為影響的抽樣

| 樣本 | 直接由 JSP 回查的行為事實 | SoT 結果 |
|---|---|---|
| DSC80106 | 58–73：Ajax 只設 `onSuccess`；79：四參數；83–88：23 欄 truthy 映射；95–104：三路返回；110–124：初始化順序；235–236：`colspan=8` | 六項皆有記錄；另發現 scriptlet null 行為與空 `<title>` 記錄不足，見 V3-02/V3-03 |
| DSC32200 | 125–134：增量合計；150–173：兩個 popup 路由；196–231：確認與成功重載；233–273：雙迴圈刪除重編；329–330：未加引號序號；351–360：表頭欄位與代碼表；367–371：破損表格 | 核心行為皆有記錄；缺陷登記未把 75、112 的同型插值納入，見 V3-05 |
| AFY10100 | 58–61：熱鍵；94–140：四個 submit + 一個 Ajax；144–225：選列映射；228–313：清空；315–369：51 參數明細 URL；450–470：條件選項；1786–1919：迴圈列；1920–1927：F8 權限輸出 | 行為流程大致完整；視覺映射、資源常數與 `<%= %>` null 行為仍不可靠，見 V3-06～V3-13 |

## 3. 逐項發現

嚴重度：`H`＝直接反向重建差異，`M`＝契約／決策可能偏移，`L`＝稽核、分類或維護品質問題。

### 3.1 DSC80106

| # | 類型 | 嚴重度 | 具體證據 | 反向重建風險／修正要求 |
|---|---|---:|---|---|
| V3-01 | OVER（事實錯誤） | L | 固定樣本表 `docs/v1/samples.md` 將 DSC80106 定為「低」，SoT 第 4 行寫「中」。 | 不改畫面行為，但破壞分層比較與研究統計；層級必須直接取固定樣本資料，不允許生成者重判。 |
| V3-02 | GAP-1 | H | JSP 20、34–37、58 是 Java expression；SoT 39–44 將六處 null 輸出寫 `[UNKNOWN]`。同輪 DSC32200 40–44 已正確記為 Java `null` 會形成字串 `null/...`。 | 重建者可能錯做成空字串或站台根路徑，造成 CSS、腳本或服務位址不同。規則應把 `<%=Object%>` 的 null 輸出固定檢查為 `JspWriter.print` 語意；值提供者未知不等於輸出運算未知。 |
| V3-03 | GAP-6 | H | JSP 33 是空 `<title></title>`；SoT 只在 U-05 泛稱 PageUI 可能影響瀏覽器標題，未記錄「原始 title 空白」這個確定事實。 | 若重建時直接使用畫面標題作 `<title>`，初始文件、腳本執行前與 PageUI 失敗路徑均改變。應寫「靜態 title 空；PageUI 是否覆寫 `[UNKNOWN]`」，不可把兩者合併。 |

### 3.2 DSC32200

| # | 類型 | 嚴重度 | 具體證據 | 反向重建風險／修正要求 |
|---|---|---:|---|---|
| V3-04 | OVER（事實錯誤） | L | 固定樣本表將 DSC32200 定為「中」，SoT 第 4 行寫「高」。 | 同 V3-01；固定樣本 metadata 應由統籌注入，不讓生成模型重寫。 |
| V3-05 | GAP-6 | M | SoT D-01（第 467 行）列 57、189、244、324、351、357，卻漏掉 JSP 75 的 `<%=dispatcher%>` JS 字串與 112 的 `<%=imageBase%>` JS 字串；§3 已指出兩者含引號會破壞字面量。 | 事實散落在 §3 而缺陷索引不完整，資安／轉義決策容易只修一半。缺陷族群須用「所有命中位置」機械產生，不准手抄行號子集。 |

### 3.3 AFY10100

| # | 類型 | 嚴重度 | 具體證據 | 反向重建風險／修正要求 |
|---|---|---:|---|---|
| V3-06 | OVER（事實錯誤） | H | SoT 43–46 把 19 個 `<%=cssBase/htmlBase/dispatcher/imageBase%>` 的 null 輸出寫成 `/cm.css`、站台根腳本／圖片／動作路徑；同輪 DSC32200 已記錄 Java null 會產生 `null/...`。 | 資源與明細 URL 在 null 路徑上會被重建成另一個可請求的位址，行為直接不同。需將 EL 與 Java expression 的 null 規則分開。 |
| V3-07 | GAP-2 | M | 查詢成功契約只寫 `inputId/role/status/isReturn/dataMap/resultList/isAllow 等`（SoT 165），但 JSP 還直接消費 `INSRMAP`、`oiuIndDesc`、`saleChnlDesc`、`I_GENDER`、`PAY_TYPE` 等。 | 「等」不是可落地的回應 schema。四個整頁動作可把回應標 `[UNKNOWN]`，但本頁確定讀取的模型鍵必須完整列舉。 |
| V3-08 | GAP-5 | H | SoT 350 只寫「7 支 JS 路徑」與圖片檔名；§13 又縮成 `prototype.js`、`HotKey.js` 等短名。JSP 21–30 的完整相對路徑（例如 `/CM/js/ajax/prototype.js`、`/CM/js/ui/validation.js`）沒有完整保留。 | 重建者無法判斷目錄與同名資源，可能載入錯誤腳本。外部資源常數必須逐一保存完整 suffix，不可只保存 basename。 |
| V3-09 | GAP-7 | H | JSP 563–936 將 `PAY_AMT1..19` 分別綁到「身故」「完全失能或最高級失能」「失能扶助金」等 19 個業務標籤，且以三組、每組「項目／合計／同業合計／收件／承保」排列。SoT 89、127 只寫「19 項保障」，未保存 `PAY_AMTn ↔ 標籤 ↔ 位置`。 | 只靠 SoT 無法重建欄名、順序與金額語意；即使 API 與演算法正確，使用者看到的數字會落在錯誤保障項目。 |
| V3-10 | GAP-7 | H | JSP 1095–1707 是 10 欄、11 個資料列的編輯區；1717–1784 是 18 欄明細標頭，只有通報方式、公司、保單號碼、險種、契約生效日可排序。SoT 107–115 只留「10 欄」「18 欄」「部分可排序」。 | 無法驗證欄序、標籤／控制項成對、空白保留格、排序入口與跨欄結構；反推 UI 必然依生成者自行設計。 |
| V3-11 | OVER（事實錯誤） | H | SoT 112 聲稱保障表「部分來源列超過 16 格」。機械計數顯示 JSP 499–958 的標題列 1 格（`colspan=16`），其後各資料／表頭列都是 15 個 `<td>`。 | 重建者會替不存在的溢出欄做瀏覽器修復，得到錯誤網格。正確事實是「宣告 colspan 16，但內容列為 15 格」。 |
| V3-12 | GAP-6 / GAP-9 | L | JSP 115 使用「即時取回」，1990 使用「即時捉取」。SoT 453 把它移到「來源歷史觀察」，但規則 G4 要求用字不一致登記缺陷；同輪 DSC32200 D-13 正是依 G4 登記「電匯／劃撥」。 | 缺陷門檻跨文件不一致，後續無法可靠產出「保留或統一用字」決策清單。 |
| V3-13 | OVER（過度缺陷化） | M | SoT D-04（426）把 57 個無 name input 一概定為「資料正確性缺陷」，但 JSP 1797–1851 明確把 55 個欄位當列快取，144–218 只在選列後複製需要編輯／送出的欄位；SoT 自己也在 146 說明這個機制。 | 若依「修正缺陷」替 55 個快取加 name，四個整頁動作會開始送出每列整包資料，改變 payload。應記為「現況資料模型／落地決策」，除非能指出現況漏送了應送欄位。 |

### 3.4 SHARED-CM-includes

| # | 類型 | 嚴重度 | 文件內部證據 | 反向重建風險／修正要求 |
|---|---|---:|---|---|
| V3-14 | OVER（過度缺陷化） | L | D-14（737）把「copy 不阻止預設行為」列缺陷，同列又承認提示文字的要求是「需留存複製軌跡」，可能正是刻意允許複製並稽核。 | 可確定的事實是「允許複製＋送稽核」；是否缺陷未知，應移至決策點而非預先定罪。 |
| V3-15 | OVER（把未知前提當缺陷） | L | U-06（703）明說不知道 `getLength()` 與 iterator 次數是否可能不一致；D-20（743）卻把「若不一致會越界」登記為現況缺陷。 | 這是條件式風險，不是已證實現況。應保留在 unknown/decision，取得 `ReturnMessage` 契約後才能升級。 |
| V3-16 | GAP-6（後果等級錯置） | L | D-25（748）把未註冊浮水印卸載處理列為「僅影響維護」，D-29（752）把 context path 改變會導致稽核請求失效也列為「僅影響維護」。 | 兩者都可能使資安狀態或稽核行為失效，至少應是「影響使用者可見行為」或「影響資料正確性」。錯誤分級會讓 §17 排序失真。 |
| V3-17 | OVER（機械計數錯誤） | L | §17 決策 1（781）列出的 JS 字串伺服器插值，按其自身位置清單為 header 12 處 + msgDisplayer 9 處＝21，不是 25；§18（800–801）又把目前實際為 252/267 行的 template/rules 記為 253/268。 | 文件聲稱 K.2 全部機械通過（1065–1066），但自身仍有錯數。下一輪不應讓生成者以敘述聲稱「通過」，而要保存命令輸出摘要並由統籌重跑。 |

### 3.5 跨文件

| # | 類型 | 嚴重度 | 證據 | 要求 |
|---|---|---:|---|---|
| V3-18 | GAP-9 / OVER | M | DSC80106 對 `AlertHandler.js` 採「副作用未知，不判死碼」（381）；AFY D-12 卻把三支「無直接呼叫、但副作用未知」腳本標 `[DEAD-CODE]`（434）；共用 D-06 也在未清查引入端時標 `[DEAD-CODE]`（729）；DSC32200 D-08 又把確定未讀的局部變數、目前空操作 callback、可能被外部讀取的 DOM hidden 合併成同一死碼項。 | `[DEAD-CODE]` 必須證明「無直接呼叫、無載入副作用、無外部消費者、無反射／名稱式存取」四項；少一項就只能標 `[UNKNOWN]` 或「疑似未使用」。 |
| V3-19 | OVER-1（重複／膨脹） | L | 三份畫面 SoT 與共用 SoT 都在 §18 後再附「產出檢查清單」（DSC80106 466、DSC32200 574、AFY 512、共用 1037），重複正文計數、缺陷與查證結論；例如 DSC80106 的「23 個欄位」在正文與附錄反覆出現。 | 檢查清單應成為生成時門檻，不應完整輸出進 SoT。產物只保存「指令＋結果摘要＋失敗項」，避免 IR 被稽核自述淹沒。 |

## 4. 反向重建風險排序

| 優先 | 風險 | 對應項目 | 失真方式 |
|---:|---|---|---|
| 1 | 視覺語意與欄位語意斷裂 | V3-09、V3-10、V3-11 | 數字落入錯誤保障項目、欄序／合併錯誤、排序入口遺失 |
| 2 | 渲染階段 null 語意混淆 | V3-02、V3-06 | 把 `null/...` 改成 `/...` 或空值，資源／服務路徑不同 |
| 3 | 資源與服務契約不完整 | V3-07、V3-08 | 漏模型鍵、載入錯目錄的同名腳本 |
| 4 | 把快取／相依誤當死碼 | V3-13、V3-18 | 刪除載入副作用、把列快取意外加入 payload |
| 5 | 缺陷分級與自我稽核失真 | V3-12、V3-14～V3-17、V3-19 | 錯誤排序人工作業、對「已機械驗證」產生不當信任 |

## 5. 單一 Markdown IR 的限制

結論：**單一 Markdown 適合承載業務邏輯，但不適合單獨承載可驗證的視覺語意。** DSC80106 的小表格尚可用 §4.3 重建；AFY10100 的多區、多層表格已證明文字摘要會丟掉以下關係：

- `field-id ↔ 使用者標籤 ↔ 可見欄位位置 ↔ colspan/rowspan ↔ 樣式語意`；
- 同一欄位在查詢摘要、編輯區、明細列中的不同呈現；
- 條件列（F8）、隱藏編輯區、空資料／選列後狀態；
- 哪些欄位可排序、哪些只是文字、哪些點擊後還有 `href="#"` 的預設導覽；
- 無效 HTML 經瀏覽器修復後的實際 DOM。

Markdown 可描述這些事，但一旦完整描述，就會變成難以人工驗證的巨大座標表；v3 的 AFY 摘要則走到另一端，變得可讀但不可反推。因此下一輪應把 **一對檔案共同定義為 IR**：

```text
sot/<畫面>.md       完整業務邏輯、資料、服務、狀態、演算法、未知、缺陷
mockup/<畫面>.html  可直接開啟的視覺／結構真相，不承載正式業務邏輯
```

### 5.1 雙產物最容易發生的資訊斷裂

| 斷裂 | 典型失敗 | 強制防線 |
|---|---|---|
| 名稱漂移 | HTML 用 `payAmt1`，MD 用 `PAY_AMT1` | 每個 HTML 節點必有穩定 `data-sot-id="field.PAY_AMT1"`；MD manifest 必須逐一對應 |
| 行為複製 | HTML 寫一份 JS，MD 又寫一份演算法，兩者日後分歧 | mockup 禁止正式服務呼叫與業務運算；互動只切換預製 state snapshot |
| 只畫 happy path | 預設畫面可看，loading/empty/error/disabled/permission state 消失 | HTML 必須提供命名 state gallery；MD 的每個狀態轉換要指向 snapshot id |
| 重複列失真 | HTML 只畫一列，遺失執行期 id 重複與序號規則 | 使用 `<template data-repeat-id>`；MD 記 cardinality、key、編號與空集合行為 |
| 缺陷被「順手修掉」 | mockup 自動校正錯誤 colspan、標題或用字 | HTML 要以 `data-defect-ref` 標示保留的現況缺陷；若瀏覽器無法穩定呈現，再另列 normalized view，不得覆蓋 as-is view |
| label 只存在 HTML | MD 的服務／驗證看不出欄位業務意義 | MD manifest 必須包含 `sot-id / label / control / source / submit / html selector` 六欄，HTML 與 MD 雙向可查 |

## 6. 下一輪雙產物模板：可直接執行的改法

### 6.1 Markdown 模板調整

保留 v3 的 §0–§18，但做以下變更：

1. 在 §4 前新增「視覺 manifest」，每列必填：

   ```markdown
   | sot-id | HTML selector | 使用者標籤 | 控制型態 | 預設狀態 | 資料/行為引用 |
   | field.PAY_AMT1.summary | [data-sot-id="field.PAY_AMT1.summary"] | 身故 | 唯讀金額 | visible | §3 R-xx / §5 F-xx |
   ```

2. §4 不再用自然語言概述大表格；改列「區塊 id、父區塊、欄數、列範本、條件 state、HTML anchor」。精確 DOM、欄序、colspan/rowspan 由 HTML 擁有。
3. §5 每個欄位有永久 `field-id`；§6 每個服務有 `service-id`；§7 每個狀態有 `state-id`；§9 每條驗證有 `validation-id`；§10 每個事件有 `event-id`。HTML 只能引用這些 id，不得另造名稱。
4. §3 明拆兩列規則：`${...}`（EL）與 `<%=...%>`（Java expression）；null 行為不得互相套用。
5. §15 將標記拆成 `[DEFECT-CONFIRMED]`、`[RISK-CONDITIONAL]`、`[SUSPECTED-DEAD-CODE]`、`[DEAD-CODE-PROVEN]`，避免 V3-14/V3-15/V3-18。
6. 刪除公開產物末尾的完整 K.1–K.4 自我敘述，只保留 §18 的命令、實際輸出摘要與未通過項。

### 6.2 HTML mockup 模板要求

```html
<!doctype html>
<html lang="zh-Hant" data-sot-version="v4" data-source="AFY10100.jsp">
<head>
  <meta charset="utf-8">
  <title data-sot-id="page.static-title"></title>
  <style>/* 僅重現必要視覺；每條樣式註明來源或 UNKNOWN */</style>
</head>
<body>
  <aside class="mockup-note">視覺 mockup：不呼叫正式服務、不代替業務邏輯 SoT</aside>

  <main data-sot-id="region.page">
    <section data-sot-id="region.query" data-state-snapshot="default">…</section>
    <section data-sot-id="region.edit" data-state-snapshot="row-selected" hidden>…</section>
    <template data-repeat-id="resultList" data-key="status.index">…</template>
  </main>

  <nav data-state-gallery>
    <!-- default/loading/empty/success/error/row-selected/no-permission -->
  </nav>
</body>
</html>
```

強制規則：

- 不載入原系統 JS/CSS，不發網路請求，不內建正式驗證或金額演算法。
- 可以有一小段 mockup-only script，只能切換 `data-state-snapshot`，並在檔頭列出它不是現況業務行為。
- 每個可見文字、控制項、表格欄、條件區與重複範本都有 `data-sot-id`。
- `rowspan`、`colspan`、欄序、readonly/disabled/hidden、預設選項、按鈕存在條件必須照原始碼；疑似瀏覽器修復區另加 `data-unknown-ref`。
- 重建缺陷時預設保留 as-is；任何 normalized 示意必須放另一個 snapshot，並指回 MD 的人工作決策點。

### 6.3 生成提示詞建議

下一輪生成者提示詞可直接加入：

> 你要產出同名的 `sot/<ID>.md` 與 `mockup/<ID>.html`，兩者合起來才是 IR。先機械列舉伺服器求值、服務、表單控制項、id/name、事件、表格每列 td 數、rowspan/colspan、可見文字與外部資源完整路徑，再開始寫。Markdown 是業務／行為真相；HTML 是視覺／結構真相。兩者以 `data-sot-id` 和 Markdown manifest 一對一連結。HTML 不得呼叫服務、不得重寫業務演算法、不得偷偷修正缺陷。每個 runtime state 在 HTML 有 snapshot、在 Markdown 有 state-id；每個重複區在 HTML 用 template、在 Markdown 寫 key/cardinality/id 規則。完成後執行雙向檢查：HTML 的每個 `data-sot-id` 必須存在於 manifest，manifest 的每個 selector 必須命中 HTML，所有 JSP 可見文字與完整資源路徑必須至少命中一次。若不能由可讀範圍證明，標 `[UNKNOWN]`，不可用「等」「部分」「相關」代替列舉。

### 6.4 驗證提示詞／腳本門檻

下一輪統籌應要求生成者提供、但不把冗長結果複寫進 SoT：

```bash
# 雙向 anchor（實作時可用 repo 現有語言寫一個 check-ir-links 腳本）
# 1. 擷取 HTML 全部 data-sot-id
# 2. 擷取 MD manifest 全部 sot-id
# 3. 兩集合做差，任一方向非空即失敗

# 表格逐列格數，不再靠肉眼
awk 'BEGIN{RS="</tr>"} {n=gsub(/<[tT][dD][ >]/,"&"); if(n) print NR,n}' mockup/<ID>.html

# 禁止 mockup 夾帶正式行為
rg -n 'Ajax\.Request|fetch\(|XMLHttpRequest|\.submit\(|https?://' mockup/<ID>.html

# 禁止模糊省略
rg -n '等|部分|相關|某些|略' sot/<ID>.md
```

## 7. 收斂判定

- `N_high = 7`，不符合 `N_high == 0`。
- `N_total = 19`，不符合 `N_total ≤ 5`。
- `N_new` 因冷啟動限制待主線比較，不能宣告連續兩輪為 0。

因此 v3 **未達收斂**。下一輪不宜只微調單一 Markdown 的欄位措辭；應把 IR 改為「HTML 視覺 mockup + Markdown 完整業務邏輯」的成對產物，並先建立雙向 anchor 檢查，否則 AFY 類高密度頁面仍會在「可讀」與「可逆」之間二選一。
