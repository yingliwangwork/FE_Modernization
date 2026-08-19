# HotKey.js 公開契約

## 使用語法清單
**變數**:
- [Keys](#Keys)

**方法**:
- [HotKeys.addHotKey(hotKey, action)](#HotKeys.addHotKey(hotKey,-action))
- [ButtonAction](#ButtonAction)
    - [constructor()](#constructor())

---

## Keys
**使用範例**: `Keys.Enter`
**輸入**: 無
**輸出**:
- Keys.F1: string = "112" - F1 鍵鍵碼
- Keys.F2: string = "113" - F2 鍵鍵碼
- Keys.F3: string = "114" - F3 鍵鍵碼
- Keys.F4: string = "115" - F4 鍵鍵碼
- Keys.F5: string = "116" - F5 鍵鍵碼
- Keys.F6: string = "117" - F6 鍵鍵碼
- Keys.F7: string = "118" - F7 鍵鍵碼
- Keys.F8: string = "119" - F8 鍵鍵碼
- Keys.F9: string = "120" - F9 鍵鍵碼
- Keys.F10: string = "121" - F10 鍵鍵碼
- Keys.F11: string = "122" - F11 鍵鍵碼
- Keys.F12: string = "123" - F12 鍵鍵碼
- Keys.Backspace: string = "8" - Backspace 鍵鍵碼
- Keys.Tab: string = "9" - Tab 鍵鍵碼
- Keys.Enter: string = "13" - Enter 鍵鍵碼
- Keys.Esc: string = "27" - Esc 鍵鍵碼
- Keys.Space: string = "32" - 空白鍵鍵碼
- Keys.PageUp: string = "33" - PageUp 鍵鍵碼
- Keys.PageDown: string = "34" - PageDown 鍵鍵碼
- Keys.End: string = "35" - End 鍵鍵碼
- Keys.Home: string = "36" - Home 鍵鍵碼
- Keys.Left: string = "37" - 左方向鍵鍵碼
- Keys.Up: string = "38" - 上方向鍵鍵碼
- Keys.Right: string = "39" - 右方向鍵鍵碼
- Keys.Down: string = "40" - 下方向鍵鍵碼
- Keys.Insert: string = "45" - Insert 鍵鍵碼
- Keys.Delete: string = "46" - Delete 鍵鍵碼
- Keys.Alt: string = "Alt" - Alt 修飾鍵標記
- Keys.Ctrl: string = "Ctrl" - Ctrl 修飾鍵標記
- Keys.Shift: string = "Shift" - Shift 修飾鍵標記
**功能**:
- 提供按鍵代碼常數，供組成快速鍵註冊時之鍵值引數使用

---

## HotKeys.addHotKey(hotKey, action)
**使用範例**: `HotKeys.addHotKey(Keys.Enter, new ButtonAction(frm.btn_query));`
**輸入**:
- hotKey: string - 快速鍵鍵值，取自 Keys 常數
- action: ButtonAction - 觸發時執行之動作物件
**輸出**: 無
**功能**:
- 註冊快速鍵與對應觸發動作之關係
- 同一鍵值重複註冊時，新註冊之動作會覆蓋先前設定

---

## ButtonAction

### constructor()
**使用範例**: `new ButtonAction(frm.btn_query)`
**輸入**:
- button: 按鈕元件參照 - 觸發快速鍵時要模擬點擊之按鈕
**輸出**:
- 執行個體: ButtonAction - 快速鍵觸發時之動作物件
**功能**:
- 建立可供 HotKeys.addHotKey 註冊之按鈕觸發動作物件
