/**
 * CathayAxios 核心封裝
 * 將 axios request 獨立於 Vue 實例流程之外，讓 API 檔案可直接調用，
 * 並統一處理 loading 與錯誤訊息顯示。CathayAxios/index.js 亦有 install 到 Vue，
 * 兩種引用方式效果相同。
 * 本檔案視為獨立 JS 模組，無法使用 pinia 及 Vue 相關的全域函數或方法。
 */

import axios from "axios";
import notify from "@/assets/plugins/CathayNotification/notify.js";
import defaultLoader from "@/assets/plugins/CathayLoader/defaultLoader.js";

let needLoadingRequestCount = 0;
const showLoaderMask = true;

const $notifySuccessMethod = notify.success;
const $notifyErrorMethod = notify.error;

const $loadMaskOpen = defaultLoader.open;
const $loadMaskClose = defaultLoader.close;

const customHeaders = {
  get: {
    Accept: "application/json",
    "Content-Type": "application/x-www-form-urlencoded;charset=big5",
    "X-Requested-With": "XMLHttpRequest",
    Pragma: "no-cache",
    "Cache-Control": "no-cache, no-store",
  },
  post: {
    Accept: "application/json",
    "Content-Type": "application/x-www-form-urlencoded;charset=big5",
    "X-Requested-With": "XMLHttpRequest",
  },
  put: {
    Accept: "application/json",
    "Content-Type": "application/x-www-form-urlencoded;charset=big5",
    "X-Requested-With": "XMLHttpRequest",
  },
  delete: {
    Accept: "application/json",
    "Content-Type": "application/x-www-form-urlencoded;charset=big5",
    "X-Requested-With": "XMLHttpRequest",
  },
};

/**
 * 建立初始的 axios 物件
 * 未傳入 config 時，套用預設的 baseURL、withCredentials、headers
 * @param {object} [config] axios 設定，至少需含 baseURL、headers
 * @returns {import('axios').AxiosInstance} axios instance
 */
const createCathayDefault = (config) => {
  if (config) {
    return axios.create(config);
  }

  return axios.create({
    baseURL: import.meta.env.VITE_API_HOST,
    withCredentials: true,
    headers: customHeaders,
  });
};

const cathayAxios = createCathayDefault();

const showRtnMessage = true;
/**
 * axios 封包回傳攔截器
 */
cathayAxios.interceptors.response.use(
  (response) => {
    tryHideFullScreenLoading();
    const resp = {};
    if (import.meta.env.VITE_API_MODE === "json-server") {
      if (response.status >= 200 && response.status <= 299) {
        resp.data = {};
        resp.data.returnCode = 0;
        resp.data.msg = "";
        resp.data.data = response.data;
        return resp.data;
      }
      $notifyErrorMethod(response.data.msg || "伺服器維護中，請稍候再試!");
      return response.data;
    }
    if (response?.data?.ErrMsg?.returnCode == 0) {
      // 處理JSONData 判斷API否是否正確
      if (!response.data.jsonData) {
        response.data.jsonData = {
          error: true,
          msg: "伺服器維護中，請稍候再試!",
        };

        $notifyErrorMethod("伺服器維護中，請稍候再試!");
        return response.data;
      }

      response.data.jsonData = JSON.parse(response.data.jsonData);

      if (response.data.jsonData?.error) {
        $notifyErrorMethod(
          `${response.data.jsonData?.error.code}: ${response.data.jsonData?.error.msg}`,
        );
      }

      if (
        response.data.ErrMsg.msgDesc &&
        response.data.ErrMsg.msgmsgDesc.length > 0 &&
        showRtnMessage
      ) {
        $notifySuccessMethod(response.data.ErrMsg.msgDesc);
      }
      return response.data;
    }

    if (response?.data?.ErrMsg?.returnCode == 403) {
      location.reload();
    }

    if (showRtnMessage) {
      $notifyErrorMethod(
        response.data.ErrMsg.msgDesc || "伺服器維護中，請稍候再試!",
      );
    }
    return response.data;
  },
  (error) => {
    tryHideFullScreenLoading();
    if (showRtnMessage) {
      $notifyErrorMethod("伺服器維護中，請稍候再試!", error);
    }
    return Promise.resolve({
      jsonData: {
        code: "999",
        error: true,
        msg: "伺服器維護中，請稍候再試!",
      },
    });
  },
);

cathayAxios.interceptors.request.use((config) => {
  if (["development", "testing"].indexOf(import.meta.env.VITE_NODE_ENV) > -1) {
    /* eslint-disable no-console */
    /* 這裡已有判斷僅在開發、測試環境會顯示console */
    console.log("[CathayAxios] Request Url: " + config.url);
    /* eslint-enable no-console */
    if (import.meta.env.VITE_API_MODE === "static") {
      config.url = "static/data/" + config.url.split("?")[0] + ".json";
    }
  }

  showFullScreenLoading();
  return config;
});

/**
 * 將回傳的 blob 資料另存為檔案下載
 * @param {Blob} data 檔案內容
 * @param {string} fileName 下載檔名
 */
function download(data, fileName) {
  if (!data) {
    return;
  }
  const blob = new Blob([data], {
    type: "application/octet-stream",
  });

  if (window.navigator.msSaveOrOpenBlob) {
    // FOR IE
    window.navigator.msSaveOrOpenBlob(blob, fileName);
  } else {
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.style.display = "none";
    a.href = url;
    a.setAttribute("download", fileName);
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url); // 釋放資源
  }
}

/** 顯示全螢幕 loading 遮罩，請求數歸零時才會實際開啟 */
function showFullScreenLoading() {
  if (!showLoaderMask || !$loadMaskOpen) return;
  if (needLoadingRequestCount === 0) {
    $loadMaskOpen();
  }
  needLoadingRequestCount += 1;
}

/** 關閉全螢幕 loading 遮罩，請求數歸零時才會實際關閉 */
function tryHideFullScreenLoading() {
  if (!showLoaderMask || !$loadMaskClose) return;
  if (needLoadingRequestCount <= 0) return;

  needLoadingRequestCount -= 1;
  if (needLoadingRequestCount === 0) {
    $loadMaskClose();
  }
}

const reader = new FileReader();
/**
 * 將下載失敗回傳的 blob 轉換為 JS 物件
 * @param {Blob} blob 錯誤回應內容
 * @param {(data: object) => void} callBack 轉換完成後的回呼
 */
function transBlobToObject(blob, callBack) {
  reader.onload = function () {
    callBack(JSON.parse(this.result));
  };
  reader.readAsText(blob);
}

export default {
  /**
   * GET 請求
   * @param {string} url API 路徑
   * @param {object} [param] query 參數
   */
  get: (url, param) => {
    return cathayAxios.get(url, { params: param });
  },
  /**
   * POST 請求
   * @param {string} url API 路徑
   * @param {object} [body] 請求內容
   */
  post: (url, body) => {
    return cathayAxios.post(url, body);
  },
  /**
   * PUT 請求
   * @param {string} url API 路徑
   * @param {object} [body] 請求內容
   */
  put: (url, body) => {
    return cathayAxios.put(url, body);
  },
  /**
   * DELETE 請求
   * @param {string} url API 路徑
   * @param {object} [body] 請求內容
   */
  delete: (url, body) => {
    return cathayAxios.delete(url, { data: body });
  },
  /**
   * 上傳檔案（multipart/form-data）
   * @param {string} url API 路徑
   * @param {FormData} body 上傳內容
   */
  upload: (url, body) => {
    let _url = url;
    if (import.meta.env.VITE_API_HOST != "/") {
      _url = import.meta.env.VITE_API_HOST + "/" + url;
    }
    showFullScreenLoading();
    return axios
      .post(_url, body, {
        headers: {
          "Content-Type": " multipart/form-data;",
          "X-Requested-With": "XMLHttpRequest",
        },
        withCredentials: true,
      })
      .then((response) => {
        tryHideFullScreenLoading();
        if (response.data && response.data.ErrMsg.returnCode == 0) {
          if (
            response.data.ErrMsg.msgDesc &&
            response.data.ErrMsg.msgDesc.length > 0 &&
            showRtnMessage
          ) {
            $notifySuccessMethod(response.data.ErrMsg.msgDesc);
          }
          return Promise.resolve(response.data);
        }

        if (showRtnMessage) {
          $notifyErrorMethod(response.data.ErrMsg.msgDesc);
        }
        return Promise.resolve(response.data);
      })
      .catch((error) => {
        tryHideFullScreenLoading();
        if (showRtnMessage) {
          $notifyErrorMethod("上傳檔案至伺服器發生錯誤!", error);
        }
        return Promise.resolve(error);
      });
  },
  /**
   * 下載檔案並另存
   * @param {string} url API 路徑
   * @param {object} body 請求內容
   * @param {string} name 下載檔名
   */
  download: (url, body, name) => {
    let _url = url;
    if (import.meta.env.VITE_API_HOST != "/") {
      _url = import.meta.env.VITE_API_HOST + "/" + url;
    }
    showFullScreenLoading();
    return new Promise((resolve, reject) => {
      axios
        .post(_url, body, {
          headers: {
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
            "X-Requested-With": "XMLHttpRequest",
          },
          transformRequest: [
            function (data) {
              let ret = "";
              Object.keys(data).forEach((key) => {
                ret +=
                  encodeURIComponent(key) +
                  "=" +
                  encodeURIComponent(data[key]) +
                  "&";
              });
              return ret;
            },
          ],
          withCredentials: true,
          responseType: "blob",
        })
        .then((resp) => {
          tryHideFullScreenLoading();
          if (!resp.data || resp.data.type != "application/octet-stream") {
            // data convert to javascript object
            transBlobToObject(resp.data, function (data) {
              $notifyErrorMethod("下載失敗! " + data.msg);
              resolve(data);
            });
          } else {
            resolve(download(resp.data, name));
          }
        })
        .catch((err) => {
          tryHideFullScreenLoading();
          reject(err.data);
        });
    });
  },
  /**
   * 建立獨立的 axios instance（不套用共用攔截器）
   * @param {object} [config] axios 設定
   */
  create: (config) => {
    return createCathayDefault(config);
  },
};
