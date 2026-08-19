import { createApp } from "vue";
import vueDialog from "@/components/common/CathayDialog.vue";

export default {
  /**
   * 註冊 $alert、$confirm，需傳入 quasar plugin 供內部獨立掛載使用
   * @param {import('vue').App} app Vue app 實例
   * @param {object} appOptions 安裝選項
   * @param {object} appOptions.quasar QuasarPlugin，供內部獨立掛載的 dialog app 使用
   */
  install(app, appOptions = {}) {
    const div = document.createElement("div");
    const vueDialogApp = createApp(vueDialog);
    vueDialogApp.use(appOptions.quasar);
    const dialogComponent = vueDialogApp.mount(div);

    const publicAlertMethod = {
      success: (message, title, options) => {
        dialogComponent.openAlert(message, title, "success", options);
      },
      info: (message, title, options) => {
        dialogComponent.openAlert(message, title, "info", options);
      },
      error: (message, title, options) => {
        dialogComponent.openAlert(message, title, "error", options);
      },
    };
    app.provide("$alert", publicAlertMethod);

    app.provide("$confirm", (message, title, options) =>
      dialogComponent.openConfirm(message, title, options),
    );
  },
};
