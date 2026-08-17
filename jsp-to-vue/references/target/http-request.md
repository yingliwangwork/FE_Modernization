# HTTP請求規範

**使用方式**: `const $cathayAxios = inject('$cathayAxios')`
**必須**: 使用既有 Axios instance(`$cathayAxios`); **禁止**: 另行建立或引用其他 HTTP Client
**必須**: 呼叫路徑為相對路徑(`baseURL` 已於 instance 內設定); **禁止**: 使用絕對路徑或完整 URL
**必須**: HTTP 回應格式統一為 `{ returnCode: number, data: any }`
- **returnCode**: `'0'` 表示請求成功，非 `0` 表示失敗
- **data**: 回應資料本體
**禁止**: 在各個頁面或組件內自行處載入狀態或錯誤狀態顯示(Instance 已統一處理)
**使用範例**:
```js
const $cathayAxios = inject('$cathayAxios')
const fetchData = async () => {
  // 發出 HTTP 請求
  const res = await $cathayAxios.post('exa10001/prompt', {})
  if (res.returnCode !== 0) {
    // 錯誤處理
    return
  }
  // 成功處理
}
```