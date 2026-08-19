import { createApp } from "vue";
import {CxlLoadingForPlugin}  from "vue-cathaylife-component"; 

const div = document.createElement("div");
const vueLoadingApp = createApp(CxlLoadingForPlugin);
const loadingComponent = vueLoadingApp.mount(div);

export default {
  /**
   * 顯示全螢幕 loading 遮罩
   * @param {object} [options] CxlLoading 元件參數
   */
  open: (options) => {
    loadingComponent.open(options);
  },
  /** 關閉全螢幕 loading 遮罩 */
  close: () => {
    loadingComponent.close();
  },
};
