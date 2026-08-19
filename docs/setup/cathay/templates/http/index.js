import publicAxiosMethod from "./instance.js";

export default {
  /**
   * 註冊 $cathayAxios，可透過 inject('$cathayAxios') 或 this.$cathayAxios 取用
   * @param {import('vue').App} app Vue app 實例
   */
  install(app, options = {}) {
    app.config.globalProperties.$cathayAxios = publicAxiosMethod;
    app.provide("$cathayAxios", publicAxiosMethod);
  },
};
