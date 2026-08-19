# tabs.js 公開契約

## 使用語法清單
**方法**:
- [Tabs](#Tabs)
    - [constructor(config)](#constructor(config))
    - [select(oEvent)](#select(oEvent))
    - [removeAll()](#removeAll())

---

## Tabs
頁籤元件建構子，透過 `new Tabs(config)` 將指定容器內既有之內容區塊轉換為具備頁籤選單與換頁能力之元件執行個體。

### constructor(config)
**使用範例**:
```
var tabs = new Tabs({
    id:'tabsMenu',
    tabs:tabArray,	
    beforeSwitchShowCover: true,	
    beforeSwitch: function(info){
        var f = $(info.to);						
        var targetURL = srcs[info.to];					
        f.src = targetURL;
        var high = document.body.clientHeight;
        $$('#contents iframe').each(function(elem){
            elem.height = high;
        });
    }
});
```
**輸入**:
- config: 物件 - 頁籤元件設定物件
    - id: 文字 - 目標容器之識別代號，該容器將被取代為頁籤元件
    - tabs: 陣列 - 頁籤項目清單，每一項為物件 {id, title}；id 對應頁面上既有內容區塊之識別代號，title 為頁籤顯示文字
    - selected: 文字 - **可選**，初始選中之頁籤識別代號；未提供時，採用容器內標記為初始項目者，或第一個項目
    - all: 物件 - **可選**，提供時於頁籤選單加入一個「全部」頁籤，點選後同時展開顯示所有內容區塊
    - onClickAction: 函式(頁籤識別代號, 頁籤選單項目元素) - **可選**，使用者點擊頁籤時之回呼函式；僅於使用者實際點擊觸發，程式呼叫 select() 不會觸發
    - beforeSwitch: 函式(換頁資訊) - **可選**，切換頁籤前執行之回呼函式；換頁資訊包含 from(原頁籤代號)、from_elem(原內容元素)、to(目標頁籤代號)、to_elem(目標內容元素)
    - afterSwitch: 函式(換頁資訊) - **可選**，切換頁籤後執行之回呼函式，換頁資訊結構同上
    - beforeSwitchShowCover: 布林值 = false - **可選**，切換頁籤時是否顯示遮罩
**輸出**:
- 執行個體: Tabs - 頁籤元件控制物件，提供 select()、removeAll() 等方法
**當 config.id 缺漏、找不到對應容器、或容器內無可轉換之內容區塊時**:
- 顯示提示訊息並中止建立
**功能**:
- 將指定容器內既有之內容區塊轉換為頁籤選單與內容分頁結構，並取代原容器於頁面上之位置
- 依 selected 設定或標記為初始項目者，決定初始顯示之內容
- 監控外框尺寸變化，自動調整頁籤內容顯示區域高度

---

### select(oEvent)
**使用範例**: `tabs.select('tab1');`
**輸入**:
- oEvent: 數值或文字 - 欲切換至之頁籤：可為頁籤索引（由 0 起算），或建立時各頁籤項目設定之識別代號文字
**輸出**: 無
**功能**:
- 切換至指定頁籤並顯示對應內容
- 目標頁籤與切換前相同時，不執行任何動作

---

### removeAll()
**使用範例**: `DSA21000.tabs.removeAll();`
**輸入**: 無
**輸出**: 無
**功能**:
- 隱藏頁籤元件並移除其選單與框架結構；其下原有之內容區塊仍保留於頁面中，僅頁籤外觀與選單被移除
- 移除後，該頁籤元件執行個體無法再透過原識別代號被存取
