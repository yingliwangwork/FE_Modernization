import { Notify } from "quasar";
/**
 * 顯示Notify
 * @param {string} type - notify的類型, 會影響顯示顏色, EX: info, positive, negative, warning
 * @param {string} message - notify顯示的訊息
 * @param {number} timeout - notify顯示在畫面上的毫秒時間
 */
const showNotify = (type, message, timeout) => {
  const notifyOptions = {
    type,
    message,
    position: "bottom-right",
    progress: true,
    timeout: 10000,
  };
  if (typeof timeout === "number" && !Number.isNaN(timeout)) {
    notifyOptions.timeout = timeout;
  }
  Notify.create(notifyOptions);
};

const notify = {
  info: (message, timeout) => {
    showNotify("info", message, timeout);
  },
  success: (message, timeout) => {
    showNotify("positive", message, timeout);
  },
  error: (message, timeout) => {
    showNotify("negative", message, timeout);
  },
  warning: (message, timeout) => {
    showNotify("warning", message, timeout);
  },
};
export default notify;
