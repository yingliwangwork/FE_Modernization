import instance from './instance.js'

export default {
  /**
   * 註冊 $http，可透過 inject('$http') 或 this.$http 取用
   * @param {import('vue').App} app Vue app 實例
   */
  install(app) {
    app.config.globalProperties.$http = instance
    app.provide('$http', instance)
  },
}
