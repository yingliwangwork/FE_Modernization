# date.js 公開契約

## 使用語法清單
**變數**:
- [SimpleDateFormat.TW](#SimpleDateFormat.TW)
- [SimpleDateFormat.US](#SimpleDateFormat.US)

**方法**:
- [isROCdate(srcData)](#isROCdate(srcData))
- [isROCdate(srcData, yearLimit)](#isROCdate(srcData,-yearLimit))
- [isROCdate(srcData, yearLimit, isROCBefore)](#isROCdate(srcData,-yearLimit,-isROCBefore))
- [diffDay(str1, str2)](#diffDay(str1,-str2))
- [diffDay(str1, str2, isROC)](#diffDay(str1,-str2,-isROC))
- [diffDayROC(strRoc1, strRoc2)](#diffDayROC(strRoc1,-strRoc2))
- [diffDayY2K(str1, str2)](#diffDayY2K(str1,-str2))
- [toROC(Y2Kdate)](#toROC(Y2Kdate))
- [toY2K(ROCdate)](#toY2K(ROCdate))
- [getDutyDay(strDate, dudt, intMonth)](#getDutyDay(strDate,-dudt,-intMonth))
- [addDate(strDate, intYY, intMM, intDD)](#addDate(strDate,-intYY,-intMM,-intDD))
- [getY2KToday()](#getY2KToday())
- [getToday()](#getToday())
- [getTime()](#getTime())
- [isDate(srcDate)](#isDate(srcDate))
- [isADdate(srcData)](#isADdate(srcData))
- [isADdate(srcData, yearLimit)](#isADdate(srcData,-yearLimit))
- [stringToDate_Y2K(srcData)](#stringToDate_Y2K(srcData))
- [SimpleDateFormat](#SimpleDateFormat)
    - [constructor()](#constructor())
    - [format(inDate)](#format(inDate))

---

## 共用模式
- 民國日期字串接受以下寫法：6～7 碼不分隔數字（如 `990901`、`1000203`）、以 `/` 分隔（如 `100/10/01`）、以 `-` 分隔（如 `100-10-28`）；民國前之日期於字串最前方加負號，且年份數字為「民國前年數減一」（例如民國前 1 年 2 月 3 日為 `-000203`，民國前 2 年 2 月 3 日為 `-010203`）。
- 西元日期字串接受以下寫法：8 碼不分隔數字（如 `20110823`）、以 `/` 分隔（如 `2011/09/13`）、以 `-` 分隔（如 `2011-08-13`）。
- 多數日期格式檢核方法皆提供 `yearLimit` 參數，用以控制年度下限：**省略或未傳入 `false` 時**，西元 1931 年以前（不含）或民國 20 年以前（不含）之日期一律視為不合理格式，但西元 1911-01-01（民國 000101）視為合理日期之特例；傳入 `false` 則解除此年度下限檢核。

---

## isROCdate(srcData)
**使用範例**: `isROCdate(ROCDate)`
**輸入**:
- srcData: 字串 - 民國年月日字串
**輸出**:
- 布林值 - 是否為合法之民國日期格式（年、月、日數值皆須有效，並套用預設之年度下限檢核）
**功能**:
- 檢核輸入字串是否符合民國日期格式，並驗證年、月、日數值有效

---

## isROCdate(srcData, yearLimit)
**使用範例**: `isROCdate(value,false)`
**輸入**:
- srcData: 字串 - 民國年月日字串
- yearLimit: 布林值 - 是否套用年度下限檢核；傳入 `false` 解除限制
**輸出**:
- 布林值 - 是否為合法之民國日期格式
**功能**:
- 依 yearLimit 決定是否套用「西元 1931 年／民國 20 年以前視為不合理日期」之年度下限檢核

---

## isROCdate(srcData, yearLimit, isROCBefore)
**使用範例**: `isROCdate(k,false,true)`
**輸入**:
- srcData: 字串 - 民國年月日字串；若為民國前之日期，字串前需加負號
- yearLimit: 布林值 - 是否套用年度下限檢核
- isROCBefore: 布林值 - 是否將輸入解讀為民國前之日期
**輸出**:
- 布林值 - 是否為合法之民國日期格式
**功能**:
- 額外支援「民國前」日期格式（字串前加負號）之解析與檢核

---

## diffDay(str1, str2)
**使用範例**: `diffDay(qDate, toDay)`
**輸入**:
- str1: 字串 - 日期 1
- str2: 字串 - 日期 2
**輸出**:
- **當輸入可解析為合法日期時**: 回傳值: 數值 - 日期 2 與日期 1 相差天數（日期 2 − 日期 1）
- **當輸入無法解析為合法日期時**: 回傳值: 數值 = NaN - 非數字
**功能**:
- **當 str1 符合西元日期格式時**: 將兩個輸入值皆以西元格式解析
- **當 str1 不符合西元日期格式時**: 將兩個輸入值皆以民國格式解析，並支援民國前日期

---

## diffDay(str1, str2, isROC)
**使用範例**: `diffDay(ADATE_BEG , ADATE_END , true)`
**輸入**:
- str1: 字串 - 日期 1
- str2: 字串 - 日期 2
- isROC: 布林值 - 是否以民國日期格式解析（true）或西元日期格式解析（false）
**輸出**:
- **當輸入可解析為合法日期時**: 回傳值: 數值 - 日期 2 與日期 1 相差天數（日期 2 − 日期 1）
- **當輸入無法解析為合法日期時**: 回傳值: 數值 = NaN - 非數字
**功能**:
- 明確指定兩日期字串之格式，不進行自動判斷

---

## diffDayROC(strRoc1, strRoc2)
**使用範例**: `diffDayROC(ROCDate,'9991231')`
**輸入**:
- strRoc1: 字串 - 民國日期 1
- strRoc2: 字串 - 民國日期 2
**輸出**:
- 數值 - 民國日期 2 與民國日期 1 相差天數
**功能**:
- 固定以民國日期格式解析兩輸入字串並計算相差天數

---

## diffDayY2K(str1, str2)
**使用範例**: `diffDayY2K( DATA_STR_DATE , '${currentDate}' )`
**輸入**:
- str1: 字串 - 西元日期 1
- str2: 字串 - 西元日期 2
**輸出**:
- 數值 - 西元日期 2 與西元日期 1 相差天數
**功能**:
- 固定以西元日期格式解析兩輸入字串並計算相差天數

---

## toROC(Y2Kdate)
**使用範例**: `toROC(birthday)`
**輸入**:
- Y2Kdate: 字串 - 西元日期字串，須為 10 個字元長度（例如 `yyyy-MM-dd` 或 `yyyy/MM/dd`）
**輸出**:
- **當輸入長度為 10 個字元時**: 回傳值: 字串 - 由民國年（西元年減 1911）、月、日三段數字直接串接而成，不含分隔符
- **當輸入長度非 10 個字元時**: 回傳值: 字串 = `''` - 空字串
**功能**:
- 將西元年日期字串轉換為民國年日期字串

---

## toY2K(ROCdate)
**使用範例**: `toY2K(v)`
**輸入**:
- ROCdate: 字串 - 民國年月日字串
**輸出**:
- **當輸入為合法民國日期格式時**: 回傳值: 字串 - 轉換後之西元日期字串，格式為「西元年-月-日」，月、日不補零
- **當輸入非合法民國日期格式時**: 原樣回傳輸入值
**功能**:
- 將民國年日期字串轉換為西元年日期字串

---

## getDutyDay(strDate, dudt, intMonth)
**使用範例**: `getDutyDay(today, '10', 1)`
**輸入**:
- strDate: 字串 - 基準日期字串（格式為西元年-月-日）
- dudt: 字串 - 期望之應繳日（日期中之「日」）
- intMonth: 數值 - 相對基準日期欲往前或往後推算之月數
**輸出**:
- 字串 - 推算後之應繳日日期字串（格式為西元年-月-日）
**功能**:
- 以基準日期之當月 1 號為基準，依 intMonth 推算目標月份
- 依目標月份之實際天數（含閏年 2 月天數判斷），將期望應繳日調整為該月份合法之最大日期

---

## addDate(strDate, intYY, intMM, intDD)
**使用範例**: `addDate(QUERY_DATE_S,1,0,0)`
**輸入**:
- strDate: 字串 - 基準日期字串（格式為西元年-月-日）
- intYY: 數值 - 欲加減之年數
- intMM: 數值 - 欲加減之月數
- intDD: 數值 - 欲加減之天數
**輸出**:
- **當基準日期非空值時**: 回傳值: 字串 - 加減年月日後之日期字串，格式為西元年-月-日
- **當基準日期為空值時**: 回傳值: 字串 = `''` - 空字串
**功能**:
- 依序加減年、月、日
- **當調整後之日期在目標月份不存在時**: 自動調整為目標月份之最後一日再繼續後續運算，以避免溢位至下一個月份，例如 2 月 29 日加 1 年至非閏年

---

## getY2KToday()
**使用範例**: `getY2KToday()`
**輸入**: 無
**輸出**:
- 字串 - 今日日期（西元年格式，`yyyy-MM-dd`）
**功能**:
- 取得系統目前日期並轉換為西元年格式字串

---

## getToday()
**使用範例**: `getToday()`
**輸入**: 無
**輸出**:
- 字串 - 今日日期（民國年格式，`yyyMMdd`，不含分隔符）
**功能**:
- 取得系統目前日期並轉換為民國年格式字串

---

## getTime()
**使用範例**: `getTime().substring(0,4)`
**輸入**: 無
**輸出**:
- 字串 - 目前時刻（格式為 `HHmmss`，不含分隔符）
**功能**:
- 取得系統目前時刻並轉換為固定 6 碼之時分秒字串

---

## isDate(srcDate)
**使用範例**: `isDate(testValue)`
**輸入**:
- srcDate: 字串 - 西元年月日字串
**輸出**:
- 布林值 - 是否為合法之西元日期格式
**功能**:
- 檢核輸入字串是否符合西元日期格式，套用預設之年度下限檢核（等同於省略年度限制引數之西元日期檢核）

---

## isADdate(srcData)
**使用範例**: `isADdate(val)`
**輸入**:
- srcData: 字串 - 西元年月日字串
**輸出**:
- 布林值 - 是否為合法之西元日期格式
**功能**:
- 檢核輸入字串是否符合西元日期格式，並驗證年、月、日數值有效，套用預設之年度下限檢核

---

## isADdate(srcData, yearLimit)
**使用範例**: `isADdate(inputDate,false)`
**輸入**:
- srcData: 字串 - 西元年月日字串
- yearLimit: 布林值 - 是否套用年度下限檢核；傳入 `false` 解除限制
**輸出**:
- 布林值 - 是否為合法之西元日期格式
**功能**:
- 依 yearLimit 決定是否套用「西元 1931 年以前視為不合理日期」之年度下限檢核

---

## stringToDate_Y2K(srcData)
**使用範例**: `stringToDate_Y2K(record.EXISTS_BEGDT).getFullYear()`
**輸入**:
- srcData: 字串 - 西元年月日字串
**輸出**:
- **當輸入符合任一西元日期格式時**: 回傳值: 日期物件 - 對應之日期，可再取得其年、月、日等資訊
- **當輸入不符合任一西元日期格式時**: 回傳值: undefined - 無
**功能**:
- 將西元日期字串解析為日期物件，供後續取得年、月、日等資訊使用

---

## SimpleDateFormat

### constructor()
**使用範例**: `new SimpleDateFormat('yyy/MM/dd', SimpleDateFormat.TW)`
**輸入**:
- pattern: 字串 = `'yyyy-MM-dd'` - 日期／時間顯示格式樣式字串，可組合年（yyyy/yyy/yy/y）、月（MMMM/MMM/MM/M）、日（dd/d）、星期（EEEE/EEE/EE/E）、24 小時制時（HH/H）、12 小時制時（hh/h）、分（mm/m）、秒（ss/s）等樣式代碼，其餘字元原樣輸出
- locale: 字串 - 顯示語言環境；傳入 `SimpleDateFormat.TW` 使用中華民國之月份／星期中文名稱與民國年份換算，傳入 `SimpleDateFormat.US` 使用英文月份／星期名稱與西元年份
**輸出**:
- 執行個體: SimpleDateFormat - 已依 pattern 與 locale 設定完成之日期格式化物件
**功能**:
- 依 pattern 逐一比對各樣式代碼於樣式字串中之位置，建立格式化時之欄位輸出順序與規則

---

### format(inDate)
**使用範例**: `df.format(value)`
**輸入**:
- inDate: 字串 - 欲格式化之西元日期或日期時間字串，接受 `yyyyMMdd`、`yyyy/MM/dd`、`yyyy-MM-dd`，以及 `yyyy-MM-dd HH:mm:ss`（可含小數秒）等格式
**輸出**:
- **當輸入為可解析的非空日期字串時**: 回傳值: 字串 - 依建構時指定之 pattern 與 locale 轉換後之顯示文字
- **當輸入非字串或為空字串時**: 回傳值: 字串 = `''` - 空字串
- **當輸入不符合可解析之日期格式時**: 原樣回傳輸入值
**功能**:
- 依建構時解析出之欄位順序，依序輸出年、月（可轉換為在地化月份名稱）、日、星期（可轉換為在地化星期名稱）、時、分、秒等欄位，欄位之間原樣保留樣式字串中之其餘字元
- 民國年份欄位（yyy/yy/y 於中華民國語言環境下）會先減去 1911 再依指定位數擷取尾數
- 12 小時制欄位（hh/h）超過 12 時會減 12 換算為 12 小時制數值

---

## SimpleDateFormat.TW
**使用範例**: `new SimpleDateFormat('yyy/MM/dd', SimpleDateFormat.TW)`
**輸入**: 無
**輸出**:
- 字串 = `'tw'` - 代表中華民國語言環境之靜態常數
**功能**:
- 作為 SimpleDateFormat 建構時之 locale 引數，指定採用中文月份／星期名稱與民國年份換算

---

## SimpleDateFormat.US
**使用範例**: `new SimpleDateFormat(pattern , SimpleDateFormat.US)`
**輸入**: 無
**輸出**:
- 字串 = `'en'` - 代表美國語言環境之靜態常數
**功能**:
- 作為 SimpleDateFormat 建構時之 locale 引數，指定採用英文月份／星期名稱與西元年份
