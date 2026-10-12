# AFY10400 必要共用依賴片段契約

版本 support-v1；2026-10-12。僅支撐 AF-AFY10400，非另一 JSP 完整 scope；先完成此契約再由入口引用。[來源及 E 證據](../../renovation/AF-AFY10400/tracking.md#證據登錄)；[plan 與模擬決策](../../renovation/AF-AFY10400/plan.md)。

## CMP-01

頁面環境与操作政策。E-06（header）：功能識別由交易名稱去底線，空白時從請求路徑首個 .jsp 名稱取；識別非空才查功能資料，取首筆。功能資料非空时設定浮水印旗標，僅值 Y 為啟用；操作政策值 Y 才加以下反應。實際本頁旗標未知：[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)。

- 操作政策啟用時，載入後在整個 body 捕捉右鍵選單、列印、列印前、剪下，阻止預設及傳播；右鍵無文案，print/beforeprint 顯示「依據資安政策，不開放列印功能」，cut 顯示「依據資安政策，不開放剪下功能」。整頁列印樣式隱藏所有 body 直屬內容，仅印上述列印政策文字。
- window 捕捉 Ctrl+A/X/S/P，阻止事件；先执行一般 keydown 阻斷（無對應文案），再分別警示「依據資安政策，不開放全選功能」「依據資安政策，不開放剪下功能」「依據資安政策，不開放頁面儲存功能」「依據資安政策，不開放列印功能」。沒有 Ctrl+Q 註冊反應；雖 copy 文案常數含「依據資安政策，需留存複製軌跡，複製請改用Ctrl+Q」，本片段不顯示它。
- body copy 事件不阻止。文字来自当前 textarea 選取範圍，其他元件取視窗選取；空白群合為一個空格。非空且不同於上一筆才紀錄：每筆独立建立 60000ms 計時器清空上一筆，不取消旧計時器；先記未截斷的全文比較值。超過 5000 字時取前 4997 + `...`，傳原始正規化文字長度、功能識別及目前時間，對 %, #, &, 空格, +, ?, = 依序百分比替換。只知道向稽核服務發出資料，不能宣告日誌寫入成功。[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01) 尚無目標承接。
- 浮水印身分為登入者員編，null 才退回姓名，再 null 為空文字；時間由服務端 yyyy-MM-dd HH:mm:ss 提供；字體難字來源依 host 設定。若启用，載入时向同源 root 記入功能識別並交付身分/時間给浮水印工具；190×85、16px 微軟正黑體、旋轉 17°、alpha .07、grid 2×2 等為呼叫設定，不能證明實際圖形。mainFrame 同源會重置 root 清單。原來源 `berforeunload` 拼字及 modern 分支呼叫载入 handler、fallback 的 onload 卻呼叫清理 handler 是既有差異，不能改成正常卸載清理。[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) 工具未提供，視覺未知。
- 有 utility 且非空回應時間識別时載入後交付；有相關環境旗標则交付非空登入平台/系統/使用者旗標與平台 dispatcher。預設中文字 byte 設定非正整数時為 2；本頁欄位沒引用它。[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)。

## CMP-02

入口訊息與清除。E-07（msgDisplayer）：從回應訊息集取 description、id、sysid、type、url、code、exception，null 文字为空；description/id換行还原為換行，exception 改為 `<br>`。

底欄尋找順序：top.leftFrame.bottomFrame → parent.leftFrame.bottomFrame → top.bottomFrame → parent.bottomFrame；支援 contentWindow 与早期 frame。若底欄有 rollback 标記，清除标記并立即返回，底欄與警示都不顯示。否則有 showNotifyMsg 能力时先交付第一筆 code/description；其例外被吞掉後仍走 alert 集合。

無 exception 的每筆：code 為 0 或 99 不加警示，其他 code 加 `訊息說明:\n` + description + `\n`；有 id 加 `\n錯誤編號：\n` + id。有 exception 时加 `異常原因:` + exception + `\n`、`\n程式ID:` + sysid + `\n\n`。集合非空才顯示：WIUtil 與 jQuery 都存在走 WIUtil，否則原生 alert。WIUtil 内部 UX 未提供：[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)。

document 任意 button/submit click（全頁，包括審閱層，无豁免）尝试调用底欄 clearNotifyMsg；普通文字/選項 click 不清；缺底欄或能力則无作用。入口内新增、刪除、匯出均使用此行为。底欄呈現尺寸与生命周期未提供，不能發明永久產品底欄。

## CMP-03

非同步交換呈現。E-08（CSRUtil）与 E-09（Prototype）：本頁引入 Prototype，因而常規為 Prototype 路線；只在外部明確強制时改 jQuery 路線，实际 host 是否改動未知 [TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)。

常規：請求建立時登记活动并显示全頁 cover；初始顯示成功訊息与 cover=true。本頁沒有 timeout 設定，不能加入預設逾時。HTTP onSuccess 读取 responseJSON；缺 response/JSON 时不跑頁面 callback。response ErrMsg.returnCode=0 才跑成功 callback，否则跑失敗 callback。頁面 callback 先於共用 onComplete；因此回填/下载可能先发生，再更新底欄、弹訊息。onComplete 注销活动，若有 timeout 才取消，依有無訊息及活动数決定 cover。

有 ErrMsg：literal `\\n` 分段合為換行并 trim，先尝试底欄「訊息：」前綴，code=0 蓝色，否则红色。有字串 code 非整数且沒前綴则只加藍色前綴。底欄未提供 [TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)。无 JSON 但有 responseText 时將 `<body>` 内文及 `<br>` 換行為錯誤訊息，code=-1、id=''；無訊息且無活動时解除 cover。

系統 L./R./J./DS/DZ/QB/AN/EP/ZU：錯誤以 CMP-04 視窗顯示；錯誤 id 非空且長度>17 加 `錯誤編號：\n{id}\n訊息說明：\n`，否则仅描述。成功文字非空且成功提示啟用：EP 只解除 cover；其他上述系統顯示 CMP-04。非这些系统：无活动解除 cover；错误原生 alert，id >17 加 `錯誤編號：\n{id}\n` 再 `訊息說明：\n{描述}`；成功僅無底欄且非空且成功提示啟用時原生 alert `訊息說明：\n{描述}`。真正所属系统来自 UICore location regex（E-08），不能僅用 AF 檔名選分支。[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)。

jQuery 条件路線已定義：cover 根据 WIUtil 有無與其成功旗標选择；有 response 才讀 ErrMsg，無 ErrMsg 立即返回；先底欄，再錯誤警示（WIUtil 若有则显示，否则 alert，長 id 前缀后仅描述）；成功關閉 WIUtil cover；然后成功/失敗 callback；complete 關閉本地 cover 并 reset。非正常來源路線，不作默認要求。

## CMP-04

Prototype 自訂訊息窗（E-10）：標題「網頁訊息」，藍 #0066CC、白內文、灰確認區，「確定」，寬 180–600（訊息長×15 决定）、內文高105px可捲；水平中央、body高度四分之一加捲動。顯示時 cover與確定焦點；相同文案去重，不同文案換行累積。空訊息用「(無訊息內容)」。

「確定」click 阻止冒泡，移除窗、注销活動，无活動才解除 cover、清消息集合，最後调用已注册 callback；不清底欄。首次顯示註冊 document keypress，第一個 keypress 就移除自己；只有该次為 Enter/Esc/空白才觸發確定與阻止事件，其他鍵不關窗，後續 Esc 也無效；再開新窗重新注册。

標題按下解除標題按下监听，记录指標相對窗偏移並显示同尺寸黑框，document 监听 move/up。第一次移動阻止事件，框随偏移移动，真窗从文件移除；尚未移動时真窗仍可見。放開解除 move/up，将窗置於框的整數座標，移除框、加回窗、恢復標題按下監聽。不能简化為直接拖真窗。动态尺寸与早期全域 event 的浏览器支援尚未实测 [TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06)。

## CMP-05

表單与交換支援（E-09）：值依畫面順序获取；重名欄位輸出重复 key，单行不会自行成为 JSON 陣列。未命名、disabled、不適用 input 不傳；字串 serialize 中 LF/CRLF 正規化為 CRLF后百分比编码，空格为 +。根來源組的 table1_I_ID／table1_POLICY_NOs 只用於檢核，真正传出 Form.serialize(frm)。目標 JSON 平行数组需要明示映射，不能把临时名稱当 wire。

## CMP-06

下載交接（E-11）：下载 helper 首先同步请求 fileName，按 ErrMsg.returnCode 判定；成功回應读取 downloadFileName、downloadFileFullPath，再交給 FileDownload表單。根指定不开新窗；新建下載表單隱藏、POST 到檔案下載器，false 分支不設定新窗口 target，按目前瀏覽情境提交。既有表單且IE時另有短暫開啟／關閉舊target視窗的相容分支，不能據此宣告所有瀏覽器皆不出現窗口。Safari 非 Chrome 延至同步 request 結束才提交；失败沒有新增本頁下載動作，helper 是否能顯示由共用訊息能力决定。與目標直接 binary 下載不同：[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)。FileDownload 真實內容未提供，停止於交接。

## CMP-07

本頁樣式（E-05）：BODY 背景 #F0FBC6；內容寬97%；標題10pt粗體绿色#339900字距3pt；tbBox2 #C7E49C、10pt、21px行高、1pt padding；說明/值 #FAFBE1，標籤 #EEF1A7，列頭 #99CCFF；資料第一列 #EEF1A7、第二列 #FAFBE1，刪除重排。輸入12px、1pt字距、非對稱灰邊；按钮10pt、#006600、21px高、綠白渐层。本頁圖像與字體檔不提供 [TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)，仅保留有證據結構，不替造 icon。
