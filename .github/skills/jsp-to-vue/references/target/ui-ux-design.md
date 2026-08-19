# UI/UX 設計規範

## 樣式規範
**專案自訂樣式**: 優先使用專案提供的 Legacy SCSS(例如: `tbYellow`, `tbBlue`)
**UI元件庫樣式**: 次要使用 Quasar 元件內建的樣式屬性(例如: `color="primary"`, `text-color="primary"`)
**自訂樣式**: 最後使用 BEM 命名規範於 `<style scoped>` 中撰寫自訂樣式
**必須**: 過時樣式屬性(HTML 4.0.1) 須改為使用 HTML 5 替代屬性，例如:
| 過時屬性 | HTML 5 替代屬性 |
|---|---|
| `bgcolor` | `background-color` |
| `align` | `text-align`（文字）／`float`（區塊） |
| `width／height`（非 img/table） | `width／height`（CSS 屬性） |
| `border` | `border`（CSS 屬性） |
| `cellPadding／cellSpacing`（table） | `padding`（配合 `border-collapse`） |
| `valign` | `vertical-align` |

**禁止**: 修改或覆蓋全局樣式(例如: `!important`, `* {}`、`<style>`、`<style global>`)
**使用範例**:
```vue
<template>
  <div class="order-detail tbYellow"></div>
</template>
<style scoped>
.order-detail {
  color: green;
    
}
</style>
```

---
    
## UI元件規範
**必須**: 遵守 [Quasar 元件使用規範](./ui-ux-designs/quasar-component.md)，依據情境使用對應的元件與樣式; **禁止**: 客製化元件內部結構(`v-slot`)，導致 UI 不一致; **Exception**: 僅日期選擇器(`#append` slot)、表單容器(`#control` slot) 可接受部分客製化

---

## 版面規範
### 基礎頁面佈局
統一於根路由使用共用佈局(`BaseLayout`)，見 [路由註冊規範](./router-registration.md)
**禁止**: 於頁面自行引用 `<BaseLayout>`，或重寫基礎頁面佈局，導致 UI 不一致

### 功能頁面佈局
- **使用情境**: 功能頁面(例如: `DSA30900`、`AFY10100Detail`)
- **使用方式**: 頁面標題(畫面編號 + 功能名稱) + 頁面內容區塊(表單、表格、圖表、列表等)
- **使用範例**: [功能頁面範例](./ui-ux-designs/examples/layouts/feature-page.md)
**禁止**: 非功能頁面(例如: 登入頁面、錯誤頁面)使用功能頁面佈局