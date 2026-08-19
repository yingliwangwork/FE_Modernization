#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common"      # 兩版共用範本
TEMPLATES="$SCRIPT_DIR/templates"   # 國泰版專屬範本
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# ===== 輸出路徑設定（要調整專案目錄結構只需改這裡）=====
DEST_VITE_CONFIG="vite.config.js"                          # Vite 設定檔
DEST_ENV_DEV=".env.development"                            # 開發環境變數
DEST_ENV_PROD=".env.production"                             # 正式環境變數
DEST_APP="src/App.vue"                                       # App 根元件
DEST_MAIN="src/main.js"                                       # 應用程式進入點
DEST_QUASAR_SASS="src/assets/sass/quasar-variables.sass"    # Quasar 主題變數
DEST_QUASAR_PLUGIN="src/assets/libs/QuasarPlugin.js"         # Quasar 安裝設定
DEST_LAYOUT="src/components"                                  # BaseLayout／AppHeader／AppDrawer
DEST_WATERMARK="src/components/common"                        # WaterMaker 元件
DEST_DIALOG_COMPONENT="src/components/common"                 # CathayDialog.vue
DEST_SERVICE="src/service"                                     # 導覽選單資料
DEST_ROUTER="src/router"                                       # 路由設定
DEST_HTTP="src/assets/plugins/CathayAxios"                     # CathayAxios instance
DEST_NOTIFICATION="src/assets/plugins/CathayNotification"      # Notify 封裝
DEST_LOADER="src/assets/plugins/CathayLoader"                  # Loading 封裝
DEST_DIALOG_PLUGIN="src/assets/plugins"                         # CathayDialog.js（$alert/$confirm）
DEST_VALIDATION="src/assets/libs"                               # yup 語系／國泰自訂驗證規則
DEST_STORE="src/stores"                                         # Pinia store
DEST_UTILS="src/utils"                                           # 共用工具函式

read -rp "請輸入專案名稱 (預設: web-app): " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-web-app}"

# 將範本內的 __PROJECT_NAME__ 佔位符換成實際專案名稱（vite.config base path、AppHeader 標題）
replace_project_name() {
  sed -i.bak "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$1" && rm -f "$1.bak"
}

# 需先將國泰元件庫 tgz 放到本資料夾下
TGZ="$SCRIPT_DIR/vue-cathaylife-component.tgz"
if [ ! -f "$TGZ" ]; then
  echo "錯誤: 找不到 $TGZ"
  echo "請先將國泰元件庫的 vue-cathaylife-component.tgz 放到 docs/setup/cathay/ 下再執行此腳本"
  exit 1
fi

# 1-1, 1-2：建立專案、套用 vite.config.js 與 env
echo "==> 一、專案框架建置"
cd "$REPO_ROOT"
npm create vite@latest "$PROJECT_NAME" -- --template vue --no-interactive

cp "$COMMON/framework/vite.config_v1.js" "$PROJECT_NAME/$DEST_VITE_CONFIG"
replace_project_name "$PROJECT_NAME/$DEST_VITE_CONFIG"
cp "$COMMON/framework/.env.development" "$PROJECT_NAME/$DEST_ENV_DEV"
cp "$COMMON/framework/.env.production" "$PROJECT_NAME/$DEST_ENV_PROD"

cd "$REPO_ROOT/$PROJECT_NAME"

# 2-1 ~ 2-7：清空預設範例、安裝 Quasar、主題變數、掛載插件、安裝元件庫
echo "==> 二、UI/UX 配置"
rm -rf src/style.css src/components/HelloWorld.vue src/assets public/icons.svg
cp "$COMMON/framework/App.vue" "$DEST_APP"

npm i -D @quasar/vite-plugin@latest sass-embedded@^1.93.2
npm i quasar@latest @quasar/extras@latest

mkdir -p "$(dirname "$DEST_QUASAR_SASS")"
cp "$TEMPLATES/quasar/quasar-variables.sass" "$DEST_QUASAR_SASS"

cp "$COMMON/framework/vite.config_v2.js" "$DEST_VITE_CONFIG"
replace_project_name "$DEST_VITE_CONFIG"

mkdir -p "$(dirname "$DEST_QUASAR_PLUGIN")"
cp "$COMMON/quasar/QuasarPlugin.js" "$DEST_QUASAR_PLUGIN"

cp "$TGZ" .
npm i vue-cathaylife-component.tgz

# 3-1, 3-2：浮水印元件、BaseLayout（標題＋側邊欄）
echo "==> 三、共用佈局與浮水印"
mkdir -p "$DEST_WATERMARK/modules"
cp "$TEMPLATES/watermark/modules/WaterMaker.js" "$DEST_WATERMARK/modules/WaterMaker.js"
cp "$TEMPLATES/watermark/WaterMaker.vue" "$DEST_WATERMARK/WaterMaker.vue"

mkdir -p "$DEST_LAYOUT/layout" "$DEST_SERVICE"
cp "$TEMPLATES/layout/BaseLayout.vue" "$DEST_LAYOUT/BaseLayout.vue"
cp "$TEMPLATES/layout/AppHeader.vue" "$DEST_LAYOUT/layout/AppHeader.vue"
replace_project_name "$DEST_LAYOUT/layout/AppHeader.vue"
cp "$TEMPLATES/layout/AppDrawer.vue" "$DEST_LAYOUT/layout/AppDrawer.vue"
cp "$TEMPLATES/layout/NavCollection.js" "$DEST_SERVICE/NavCollection.js"

# 4-1, 4-2：安裝 vue-router、建立路由設定
echo "==> 四、路由設定"
npm i vue-router@latest

mkdir -p "$DEST_ROUTER"
cp "$COMMON/router/index.js" "$DEST_ROUTER/index.js"
cp "$COMMON/router/router.js" "$DEST_ROUTER/router.js"

# 5-1, 5-2：安裝 axios、建立 CathayAxios + Notification + Loader + Dialog
echo "==> 五、HTTP Client"
npm i axios

mkdir -p "$DEST_HTTP" "$DEST_NOTIFICATION" "$DEST_LOADER"
cp "$TEMPLATES/http/index.js" "$DEST_HTTP/index.js"
cp "$TEMPLATES/http/instance.js" "$DEST_HTTP/instance.js"
cp "$TEMPLATES/notification/index.js" "$DEST_NOTIFICATION/index.js"
cp "$TEMPLATES/notification/notify.js" "$DEST_NOTIFICATION/notify.js"
cp "$TEMPLATES/loader/index.js" "$DEST_LOADER/index.js"
cp "$TEMPLATES/loader/defaultLoader.js" "$DEST_LOADER/defaultLoader.js"
cp "$TEMPLATES/dialog/CathayDialog.js" "$DEST_DIALOG_PLUGIN/CathayDialog.js"
cp "$TEMPLATES/dialog/CathayDialog.vue" "$DEST_DIALOG_COMPONENT/CathayDialog.vue"
cat "$TEMPLATES/http/.env.api" >> "$DEST_ENV_DEV"
cat "$TEMPLATES/http/.env.api" >> "$DEST_ENV_PROD"

# 6-1 ~ 6-3：安裝 vee-validate/yup、語系、國泰自訂規則
echo "==> 六、表單驗證"
npm i vee-validate yup @vee-validate/yup

mkdir -p "$DEST_VALIDATION"
cp "$COMMON/validation/YupZhTw.js" "$DEST_VALIDATION/YupZhTw.js"
cp "$TEMPLATES/validation/CathayValidateRules.js" "$DEST_VALIDATION/CathayValidateRules.js"

# 7-1, 7-2：安裝 pinia、建立 auth store
echo "==> 七、狀態管理（Pinia）"
npm i pinia

mkdir -p "$DEST_STORE"
cp "$COMMON/store/auth.js" "$DEST_STORE/auth.js"

# 8-1：建立共用工具（純函式，不需 main.js 掛載）
echo "==> 八、共用工具"
mkdir -p "$DEST_UTILS"
cp "$TEMPLATES/utils/format.js" "$DEST_UTILS/format.js"
cp "$TEMPLATES/utils/common.js" "$DEST_UTILS/common.js"
cp "$TEMPLATES/utils/TableDragDrop.js" "$DEST_UTILS/TableDragDrop.js"

# main.js 統一在最後掛載，避免中間步驟互相覆蓋
echo "==> 掛載 main.js"
cp "$TEMPLATES/main/main_v2.js" "$DEST_MAIN"

echo "==> 完成！專案已建立於 $REPO_ROOT/$PROJECT_NAME"

read -rp "是否要啟動專案（npm run dev）? (y/N): " RUN_DEV
if [[ "$RUN_DEV" =~ ^[Yy]$ ]]; then
  cd "$REPO_ROOT/$PROJECT_NAME" && npm run dev
fi
