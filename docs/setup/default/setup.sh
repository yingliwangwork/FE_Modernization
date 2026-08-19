#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common"      # 兩版共用範本
TEMPLATES="$SCRIPT_DIR/templates"   # 預設版專屬範本
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# ===== 輸出路徑設定（要調整專案目錄結構只需改這裡）=====
DEST_VITE_CONFIG="vite.config.js"                         # Vite 設定檔
DEST_ENV_DEV=".env.development"                           # 開發環境變數
DEST_ENV_PROD=".env.production"                            # 正式環境變數
DEST_APP="src/App.vue"                                      # App 根元件
DEST_MAIN="src/main.js"                                      # 應用程式進入點
DEST_QUASAR_SASS="src/assets/sass/quasar-variables.sass"   # Quasar 主題變數
DEST_QUASAR_PLUGIN="src/assets/libs/QuasarPlugin.js"        # Quasar 安裝設定
DEST_LAYOUT="src/components"                                 # BaseLayout／AppHeader／AppDrawer
DEST_WATERMARK="src/components/modules"                      # 浮水印模組
DEST_SERVICE="src/service"                                   # 導覽選單資料
DEST_ROUTER="src/router"                                      # 路由設定
DEST_HTTP="src/assets/plugins/axios"                          # axios instance
DEST_VALIDATION="src/assets/libs"                             # yup 語系／自訂驗證規則
DEST_STORE="src/stores"                                       # Pinia store

read -rp "請輸入專案名稱 (預設: web-app): " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-web-app}"

# 將範本內的 __PROJECT_NAME__ 佔位符換成實際專案名稱（vite.config base path、AppHeader 標題）
replace_project_name() {
  sed -i.bak "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$1" && rm -f "$1.bak"
}

# 1-1, 1-2：建立專案、套用 vite.config.js 與 env
echo "==> 一、專案框架建置"
cd "$REPO_ROOT"
npm create vite@latest "$PROJECT_NAME" -- --template vue --no-interactive

cp "$COMMON/framework/vite.config_v1.js" "$PROJECT_NAME/$DEST_VITE_CONFIG"
replace_project_name "$PROJECT_NAME/$DEST_VITE_CONFIG"
cp "$COMMON/framework/.env.development" "$PROJECT_NAME/$DEST_ENV_DEV"
cp "$COMMON/framework/.env.production" "$PROJECT_NAME/$DEST_ENV_PROD"

cd "$REPO_ROOT/$PROJECT_NAME"

# 2-1 ~ 2-5：清空預設範例、安裝 Quasar、主題變數、掛載插件
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

# 3-1, 3-2：浮水印模組、BaseLayout（標題＋側邊欄）
echo "==> 三、共用佈局與浮水印"
mkdir -p "$DEST_WATERMARK"
cp "$TEMPLATES/watermark/water-maker.js" "$DEST_WATERMARK/water-maker.js"

mkdir -p "$DEST_LAYOUT/layout" "$DEST_SERVICE"
cp "$TEMPLATES/layout/BaseLayout.vue" "$DEST_LAYOUT/BaseLayout.vue"
cp "$TEMPLATES/layout/AppHeader.vue" "$DEST_LAYOUT/layout/AppHeader.vue"
replace_project_name "$DEST_LAYOUT/layout/AppHeader.vue"
cp "$TEMPLATES/layout/AppDrawer.vue" "$DEST_LAYOUT/layout/AppDrawer.vue"
cp "$TEMPLATES/layout/nav-collection.js" "$DEST_SERVICE/nav-collection.js"

# 4-1, 4-2：安裝 vue-router、建立路由設定
echo "==> 四、路由設定"
npm i vue-router@latest

mkdir -p "$DEST_ROUTER"
cp "$COMMON/router/index.js" "$DEST_ROUTER/index.js"
cp "$COMMON/router/router.js" "$DEST_ROUTER/router.js"

# 5-1, 5-2：安裝 axios、建立 instance
echo "==> 五、HTTP Client"
npm i axios

mkdir -p "$DEST_HTTP"
cp "$TEMPLATES/http/instance.js" "$DEST_HTTP/instance.js"
cp "$TEMPLATES/http/index.js" "$DEST_HTTP/index.js"
cat "$TEMPLATES/http/.env.api" >> "$DEST_ENV_DEV"
cat "$TEMPLATES/http/.env.api" >> "$DEST_ENV_PROD"

# 6-1 ~ 6-3：安裝 vee-validate/yup、語系、自訂規則
echo "==> 六、表單驗證"
npm i vee-validate yup @vee-validate/yup

mkdir -p "$DEST_VALIDATION"
cp "$COMMON/validation/YupZhTw.js" "$DEST_VALIDATION/YupZhTw.js"
cp "$TEMPLATES/validation/ValidateRules.js" "$DEST_VALIDATION/ValidateRules.js"

# 7-1, 7-2：安裝 pinia、建立 auth store
echo "==> 七、狀態管理（Pinia）"
npm i pinia

mkdir -p "$DEST_STORE"
cp "$COMMON/store/auth.js" "$DEST_STORE/auth.js"

# main.js 統一在最後掛載，避免中間步驟互相覆蓋
echo "==> 掛載 main.js"
cp "$TEMPLATES/main/main_v1.js" "$DEST_MAIN"

echo "==> 完成！專案已建立於 $REPO_ROOT/$PROJECT_NAME"

read -rp "是否要啟動專案（npm run dev）? (y/N): " RUN_DEV
if [[ "$RUN_DEV" =~ ^[Yy]$ ]]; then
  cd "$REPO_ROOT/$PROJECT_NAME" && npm run dev
fi
