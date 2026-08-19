# 前端專案建置步驟說明(國泰)

## 一、專案框架建置

### 1-1 建立 Vue 3 專案

```bash
# 於 repo 根目錄執行
PROJECT_NAME=web-app  # 請替換為目標專案名稱
npm create vite@latest "$PROJECT_NAME" -- --template vue --no-interactive
```

### 1-2 設定 vite.config.js 與環境變數

```bash
# 於 repo 根目錄執行
cp docs/setup/common/framework/vite.config_v1.js "$PROJECT_NAME/vite.config.js"
sed -i.bak "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$PROJECT_NAME/vite.config.js" && rm -f "$PROJECT_NAME/vite.config.js.bak"
cp docs/setup/common/framework/.env.development "$PROJECT_NAME/.env.development"
cp docs/setup/common/framework/.env.production "$PROJECT_NAME/.env.production"
```

## 二、UI/UX 配置

### 2-1 清除預設範例、套用共用 App.vue

```bash
cd "$PROJECT_NAME"
rm -rf src/style.css src/components/HelloWorld.vue src/assets public/icons.svg
cp ../docs/setup/common/framework/App.vue src/App.vue
```

### 2-2 安裝 Quasar 套件

```bash
npm i -D @quasar/vite-plugin@latest sass-embedded@^1.93.2
npm i quasar@latest @quasar/extras@latest # (可選) icon 字型/圖示集
```

### 2-3 建立主題變數檔

```bash
mkdir -p src/assets/sass
cp ../docs/setup/cathay/templates/quasar/quasar-variables.sass src/assets/sass/quasar-variables.sass
```

### 2-4 設定 vite.config.js 整合 Quasar 插件

```bash
cp ../docs/setup/common/framework/vite.config_v2.js vite.config.js
sed -i.bak "s/__PROJECT_NAME__/$PROJECT_NAME/g" vite.config.js && rm -f vite.config.js.bak
```

### 2-5 建立 QuasarPlugin.js

```bash
mkdir -p src/assets/libs
cp ../docs/setup/common/quasar/QuasarPlugin.js src/assets/libs/QuasarPlugin.js
```

### 2-6 安裝國泰元件庫

```bash
cp ../docs/setup/cathay/vue-cathaylife-component.tgz . && npm i vue-cathaylife-component.tgz
```

### 2-7 於 main.js 掛載 Quasar 與元件庫樣式

```bash
cp ../docs/setup/cathay/templates/main/main_v1.js src/main.js
```

## 三、共用佈局與浮水印

### 3-1 建立浮水印元件

```bash
mkdir -p src/components/common/modules
cp ../docs/setup/cathay/templates/watermark/modules/WaterMaker.js src/components/common/modules/WaterMaker.js
cp ../docs/setup/cathay/templates/watermark/WaterMaker.vue src/components/common/WaterMaker.vue
```

### 3-2 建立 BaseLayout（標題＋側邊欄）

```bash
mkdir -p src/components/layout src/service
cp ../docs/setup/cathay/templates/layout/BaseLayout.vue src/components/BaseLayout.vue
cp ../docs/setup/cathay/templates/layout/AppHeader.vue src/components/layout/AppHeader.vue
sed -i.bak "s/__PROJECT_NAME__/$PROJECT_NAME/g" src/components/layout/AppHeader.vue && rm -f src/components/layout/AppHeader.vue.bak
cp ../docs/setup/cathay/templates/layout/AppDrawer.vue src/components/layout/AppDrawer.vue
cp ../docs/setup/cathay/templates/layout/NavCollection.js src/service/NavCollection.js
```

## 四、路由設定

### 4-1 安裝 vue-router

```bash
npm i vue-router@latest
```

### 4-2 建立路由設定檔

```bash
mkdir -p src/router
cp ../docs/setup/common/router/index.js src/router/index.js
cp ../docs/setup/common/router/router.js src/router/router.js
```

### 4-3 於 main.js 掛載路由

```bash
cp ../docs/setup/cathay/templates/main/main_v1.js src/main.js
```

## 五、HTTP Client

### 5-1 安裝 axios

```bash
npm i axios
```

### 5-2 建立 CathayAxios 與相關配置（Notification、Loader、Dialog）

```bash
mkdir -p src/assets/plugins/CathayAxios src/assets/plugins/CathayNotification src/assets/plugins/CathayLoader
cp ../docs/setup/cathay/templates/http/index.js src/assets/plugins/CathayAxios/index.js
cp ../docs/setup/cathay/templates/http/instance.js src/assets/plugins/CathayAxios/instance.js
cp ../docs/setup/cathay/templates/notification/index.js src/assets/plugins/CathayNotification/index.js
cp ../docs/setup/cathay/templates/notification/notify.js src/assets/plugins/CathayNotification/notify.js
cp ../docs/setup/cathay/templates/loader/index.js src/assets/plugins/CathayLoader/index.js
cp ../docs/setup/cathay/templates/loader/defaultLoader.js src/assets/plugins/CathayLoader/defaultLoader.js
cp ../docs/setup/cathay/templates/dialog/CathayDialog.js src/assets/plugins/CathayDialog.js
cp ../docs/setup/cathay/templates/dialog/CathayDialog.vue src/components/common/CathayDialog.vue
cat ../docs/setup/cathay/templates/http/.env.api >> .env.development
cat ../docs/setup/cathay/templates/http/.env.api >> .env.production
```

### 5-3 於 main.js 掛載

```bash
cp ../docs/setup/cathay/templates/main/main_v2.js src/main.js
```

## 六、表單驗證

### 6-1 安裝 vee-validate、yup

```bash
npm i vee-validate yup @vee-validate/yup
```

### 6-2 建立 yup 本地化語系

```bash
mkdir -p src/assets/libs
cp ../docs/setup/common/validation/YupZhTw.js src/assets/libs/YupZhTw.js
```

### 6-3 建立國泰自訂驗證規則

```bash
cp ../docs/setup/cathay/templates/validation/CathayValidateRules.js src/assets/libs/CathayValidateRules.js
```

### 6-4 於 main.js 掛載

```bash
cp ../docs/setup/cathay/templates/main/main_v2.js src/main.js
```

## 七、狀態管理（Pinia）

### 7-1 安裝 pinia

```bash
npm i pinia
```

### 7-2 建立 auth store 骨架

```bash
mkdir -p src/stores
cp ../docs/setup/common/store/auth.js src/stores/auth.js
```

### 7-3 於 main.js 掛載

```bash
cp ../docs/setup/cathay/templates/main/main_v2.js src/main.js
```

## 八、共用工具

### 8-1 建立 utils

```bash
mkdir -p src/utils
cp ../docs/setup/cathay/templates/utils/format.js src/utils/format.js
cp ../docs/setup/cathay/templates/utils/common.js src/utils/common.js
cp ../docs/setup/cathay/templates/utils/TableDragDrop.js src/utils/TableDragDrop.js
```