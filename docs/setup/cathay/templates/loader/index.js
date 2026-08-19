import defaultLoader from "./defaultLoader.js";

export default {
  /**
   * 註冊 $loader，可透過 inject('$loader') 或 this.$loader 取用
   * @param {import('vue').App} app Vue app 實例
   */
  install(app, appOptions = {}) {
    app.provide("$loader", defaultLoader);
    app.config.globalProperties.$loader = defaultLoader;
  },
};
