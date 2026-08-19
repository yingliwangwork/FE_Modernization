import { setLocale } from "yup";

/** yup 內建驗證錯誤訊息繁體中文化 */
setLocale({
  mixed: {
    default: "無效的 ${path}",
    required: "${path} 是必填欄位",
    oneOf: "${path} 必須是以下值之一: ${values}",
    notOneOf: "${path} 不能是以下值之一: ${values}",
    defined: "必須定義 ${path}",
  },
  string: {
    length: "${path} 長度必須正好是 ${length} 碼",
    min: "${path} 長度必須至少有 ${min} 碼",
    max: "${path} 長度最多只能有 ${max} 碼",
    matches: '${path} 必須匹配以下內容: "${regex}"',
    email: "${path} 必須是有效的電子郵件地址格式",
    url: "${path} 必須是有效的 URL位址",
    uuid: "${path} 必須是有效的 UUID",
    trim: "${path} 必須是裁切後的字串",
    lowercase: "${path} 必須是小寫字串",
    uppercase: "${path} 必須是大寫字串",
  },
  number: {
    min: "${path} 必須大於或等於 ${min}",
    max: "${path} 必須小於或等於 ${max}",
    lessThan: "${path} 必須小於 ${less}",
    moreThan: "${path} 必須大於 ${more}",
    positive: "${path} 必須是正數",
    negative: "${path} 必須是負數",
    integer: "${path} 必須是整數",
  },
  date: {
    min: "${path} 必須在 ${min} 之後",
    max: "${path} 必須在 ${max} 之前",
  },
  boolean: { isValue: "${path} 必須是 ${value}" },
  object: { noUnknown: "${path} 有未指定的值: ${unknown}" },
  array: {
    min: "${path} 必須至少有 ${min} 個項目",
    max: "${path} 必須少於或等於 ${max} 個項目",
    length: "${path} 必須有 ${length} 個項目",
  },
});
