# calendar.js 公開契約

> 原始資源：`/CM/js/calendar.js`

## **`getCalendarFor(elem)`**

### 用途

- 外部模組要立即為單一日期欄位開啟共用日期選擇器時使用。

### 輸入

- `elem`: [String|InputElement] - 日期輸入欄位本身，或可由 `id`、`name` 解析為欄位的字串。
  - `elem.datatype`: [String = "DATE"] - 紀年與地區呈現模式；大小寫不拘，請參閱[代碼對照表](#代碼對照表)。
  - `elem.pattern`: [String = undefined] - 日期顯示格式；提供時覆蓋 `datatype` 的預設格式，但不改變紀年換算與介面語系。
  - `elem.disabled`: [Boolean = false] - `true` 時不開啟。
  - `elem.readonly`: [Boolean = false] - `true` 時不開啟；原始碼讀取小寫屬性名稱。

### 輸出

- `return`: [undefined] - 原始函式不回傳日期選擇器或選取值。

### 對外功能

- 解析欄位的 `datatype`、`pattern` 與現有值，開啟相符紀年、日期順序及介面語系的日期選擇器。
- 使用者選取日期後，直接將格式化結果寫回 `elem.value`。

### 副作用

- 首次呼叫時建立共用日期選擇介面、尺寸偵測節點與滑鼠狀態節點。
- 將指定欄位設為目前操作目標，加入工作中視覺標記、顯示日期選擇器並移動焦點。
- 欄位不是有效輸入元素、與目前目標相同、已停用或唯讀時不執行任何處理。

---

## **`autoCreateDate(elem)`**

### 用途

- 外部模組要批次掃描一個頁面範圍，並依各日期欄位的 `datatype` 自動配置輸入格式與日期選擇行為時使用。

### 輸入

- `elem`: [String|Element = document.body] - 要處理的單一輸入欄位、容器或其識別；解析失敗時改掃描整個頁面主體。
- `input`: [InputElement] - `elem` 範圍內每個候選輸入欄位。
  - `input.datatype`: [String] - 只有以 `DATE` 開頭或結尾的值會被配置；大小寫不拘，模式請參閱[代碼對照表](#代碼對照表)。
  - `input.pattern`: [String = undefined] - 日期顯示格式；必須含 `yy` 至 `yyyy`、`MM` 或 `MMM`、`dd`。
  - `input.value`: [String = ""] - 初始日期值；符合 `YYYY?MM?DD` 且使用非預設地區或自訂格式時會轉為目標顯示格式。

### 輸出

- `return`: [undefined] - 原始函式不回傳已配置欄位集合。

### 對外功能

- 依各欄位的日期模式設定輸入長度、最大長度、日期格式與鍵盤／滑鼠操作。
- 支援按鍵選取今日、清除、逐日／逐週移動、切換月份與年份層級。

### 副作用

- 為符合條件的欄位加入 `calendar_input` 樣式識別及 `focus`、`click`、`blur`、`keyup`、`keydown` 行為。
- 欄位後方已有來源檔名為 `cal.gif`、`calendar.gif` 或 `icon_calendar.gif` 的舊式圖示時，公開入口不會移除圖示，而是略過該欄位。
- 可能改寫欄位的 `size`、`maxLength` 與初始 `value`。
- 完成掃描後若存在全域 `autoFormatToDate`，會延遲約 500 毫秒執行它。

## 代碼對照表

### `datatype` 地區與語系模式

| `datatype` | 紀年與預設格式 | 月份文字 | 星期標題 | 操作標籤與年份標題 |
|---|---|---|---|---|
| `DATE` | 西元，`yyyy-MM-dd` | 中文一月至十二月 | `日、一、二、三、四、五、六` | `今`、`清`；西元年份不加前後綴 |
| `ROCDATE` | 民國紀年，`yyyMMdd` | 中文一月至十二月 | `日、一、二、三、四、五、六` | `今`、`清`；年份以前綴「民國」及後綴「年」呈現，讀寫時與西元年互換 |
| `VNDATE` | 西元、日／月／年順序，`dd/MM/yyyy` | `JAN` 至 `DEC` | `S、M、T、W、T、F、S` | `T`、`C`；西元年份不加前後綴 |
| 其他以 `DATE` 開頭或結尾的值 | 西元，`yyyy-MM-dd` | 中文一月至十二月 | `日、一、二、三、四、五、六` | 沒有專屬地區規則時沿用 `DATE` 的中文介面 |

### 日期格式符號

| 符號 | 語意 |
|---|---|
| `yy`、`yyy`、`yyyy` | 年份；`ROCDATE` 會先換算為民國年。 |
| `MM` | 兩位數月份。 |
| `MMM` | 地區模式定義的月份名稱或縮寫。 |
| `dd` | 日期。 |

`pattern` 只改變日期文字的欄位順序、分隔符號及顯示長度，不會將 `ROCDATE` 或 `VNDATE` 切換成其他地區模式。
