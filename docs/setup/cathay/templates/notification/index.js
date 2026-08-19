import notify from "./notify.js";

export default {
  /**
   * 註冊 $notify，可透過 inject('$notify') 或 this.$notify 取用
   * @param {import('vue').App} app Vue app 實例
   */
  install(app, options = {}) {
    app.provide("$notify", notify);
    app.config.globalProperties.$notify = notify;
  },
};
