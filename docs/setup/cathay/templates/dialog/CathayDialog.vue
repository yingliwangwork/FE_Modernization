<template>
  <!-- Alert -->
  <CxlInfo
    v-model="settingAlert.isShowAlert"
    :title="settingAlert.title"
    :closeText="settingAlert.closeText"
    :status="settingAlert.status"
    :size="settingAlert.size"
    :persistent="settingAlert.isFocus"
    @buttonClick="clickInfoBtn"
  >
    <template v-if="settingAlert.compileHtml">
      <div v-html="settingAlert.message"></div>
    </template>
    <template v-else>
      <p class="cxl-font-18">{{ settingAlert.message }}</p>
    </template>
  </CxlInfo>

  <!-- Confirm -->
  <CxlModal
    v-model="settingConfirm.isShowModal"
    :title="settingConfirm.title"
    :subtitle="settingConfirm.subtitle"
    :cancelText="settingConfirm.cancelText"
    :confirmText="settingConfirm.confirmText"
    :size="settingConfirm.size"
    :persistent="settingConfirm.isFocus"
    allow-focus-outside
    @hide="settingConfirm.isDialogHide = true"
    @confirm="confirm"
    @cancel="cancel"
  >
    <template v-if="settingConfirm.compileHtml">
      <div v-html="settingConfirm.confirmMessage"></div>
    </template>
    <template v-else>
      <p class="cxl-font-18">{{ settingConfirm.confirmMessage }}</p>
    </template>
  </CxlModal>
</template>

<script setup>
import { reactive } from "vue";
import { CxlModal, CxlInfo} from "vue-cathaylife-component"; 

const infoStatusMap = {
  success: "positive",
  info: "neutral",
  error: "negative",
};

const settingAlert = reactive({
  message: "",
  title: "",
  closeText: "",
  status: "",
  size: "",
  compileHtml: false,
  isFocus: false,
  isShowAlert: false,
});

/**
 * 透過傳入的參數, 控制quasar的Alert dialog套件
 * @param {string} msg - alertMsg
 * @param {string} inputTitle - title顯示的文字顏色
 * @param {string} type - alertType, EX: success, info, error
 * @param {object} [options] - more custom options
 * @param {string} options.closeText - 關閉彈跳視窗的按鈕文字
 * @param {string} options.status - title顯示的文字顏色, EX: positive, neutral, negative
 * @param {string} options.size - 彈跳視窗的大小
 * @param {boolean} options.compileHtml - 是否使用v-html顯示內容(慎用, 可能會造成XSS攻擊)
 * @param {boolean} options.isFocus - 點擊彈跳視窗外面是否不會自動關閉視窗
 */
const openAlert = (msg, inputTitle, type, options = {}) => {
  if (type) {
    settingAlert.status = infoStatusMap[type] || "neutral";
  } else {
    settingAlert.status = options.status || "neutral";
  }
  settingAlert.title = inputTitle || "";
  settingAlert.message = msg || "";
  settingAlert.closeText = options.closeText || "關閉";
  settingAlert.size = options.size || "sm";
  settingAlert.compileHtml = !!options.compileHtml;
  settingAlert.isFocus = !!options.isFocus;
  settingAlert.isShowAlert = true;
};

const clickInfoBtn = () => {
  settingAlert.isShowAlert = false;
};

let resolveEvent;
const settingConfirm = reactive({
  title: "",
  subtitle: "",
  confirmMessage: "",
  cancelText: "",
  confirmText: "",
  size: "",
  compileHtml: false,
  isDialogHide: true,
  isFocus: false,
  isShowModal: false,
});

/**
 * 透過傳入的參數, 控制quasar的Confirm dialog套件
 * @param {string} msg - confirmMsg
 * @param {string} inputTitle - confirmTitle
 * @param {object} [options] - more custom options
 * @param {string} options.subtitle - 副標題
 * @param {string} options.cancelText - 彈跳視窗的按鈕文字: 取消
 * @param {string} options.confirmText - 彈跳視窗的按鈕文字: 確認
 * @param {string} options.size - 彈跳視窗的大小
 * @param {boolean} options.compileHtml - 是否使用v-html顯示內容(慎用, 可能會造成XSS攻擊)
 * @param {boolean} options.isFocus - 點擊彈跳視窗外面是否不會自動關閉視窗
 * @returns {Promise} 如果有按下 **確認按鈕** 就回傳 **true**
 */
const openConfirm = (msg, inputTitle, options = {}) => {
  settingConfirm.confirmMessage = msg || "";
  settingConfirm.title = inputTitle || "確認提示";
  settingConfirm.subtitle = options.subtitle || "";
  settingConfirm.cancelText = options.cancelText || "取消";
  settingConfirm.confirmText = options.confirmText || "確認";
  settingConfirm.size = options.size || "sm";
  settingConfirm.isFocus = !!options.isFocus;
  settingConfirm.compileHtml = !!options.compileHtml;
  settingConfirm.isDialogHide = false;
  settingConfirm.isShowModal = true;

  return new Promise((resolve) => {
    resolveEvent = () => resolve(true);
  });
};

/**
 * 防止Promise hang住, 將resolve從resolveEvent移除
 */
const confirm = () => {
  resolveEvent();
  resolveEvent = null;
  settingConfirm.isShowModal = false;
};

const cancel = () => {
  settingConfirm.isShowModal = false;
};

defineExpose({ openAlert, openConfirm });
</script>
