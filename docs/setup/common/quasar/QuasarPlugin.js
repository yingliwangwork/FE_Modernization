import { Quasar, Loading, Notify, Dialog } from "quasar";
import quasarLang from "quasar/lang/zh-TW.js";
import "quasar/src/css/index.sass";
import "quasar/src/css/flex-addon.sass";
// (可選) icon 字型集
import "@quasar/extras/material-icons/material-icons.css";

export default {
  /**
   * 安裝 Quasar 與所需的 plugins（Loading、Notify、Dialog）
   * @param {import('vue').App} app Vue app 實例
   */
  install(app, options = {}) {
    app.use(Quasar, {
      plugins: { Loading, Notify, Dialog },
      lang: quasarLang,
    });
  },
};
