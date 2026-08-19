import { string, number, date, addMethod } from "yup";

/**
 * 自訂 yup 驗證規則，新增規則請比照以下格式：
 *
 * addMethod(string, "customRule", function (errMsg = "自訂驗證規則錯誤") {
 *   return this.test({
 *     name: "customRule",
 *     message: errMsg,
 *     test: (value, context) => {
 *       // 撰寫驗證邏輯，回傳 true 表示通過、false 表示失敗
 *       return true;
 *     },
 *   });
 * });
 */