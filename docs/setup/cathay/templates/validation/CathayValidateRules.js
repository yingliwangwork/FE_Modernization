/**
 * --- 檢核規則 ---
 * mobile (string): 驗證行動電話
 * isChar (string): 驗證是否為Char
 * dateformatvalid (string): 驗證日期格式(YYYYMMDD)
 * validateNumber (string): 檢核有效數字格式
 * validateAlpha (string): 檢核英文字母
 * validateDate (string): 檢核有效日期格式
 * validateDateDb (string): 檢核有效日期格式 YYYY-MM-DD
 * validateROCDate (string): 檢核正確的民國日期格式
 * validateDateYM (string): 檢核正確之西元年月格式
 * validateROCDateYM (string): 檢核正確之民國年月格式
 * validateHHMM (string): 檢核時分格式(HH:MM) (24小時制)
 * validateHHMMMax (string): 檢核開始時間不得大於結束時間 (HH:MM)
 * validateHHMMMin (string): 檢核結束時間不得小於開始時間 (HH:MM)
 * validateROCDateMax (string): 檢核民國起日不得大於迄日
 * validateROCDateMin (string): 檢核民國迄日不得小於起日
 * validatorROCID (string): 身分證檢核
 * validatorResidentID (string): 居留證檢核
 * --- 工具---
 * skipEmptyStr: 針對number或date時，可以將空字串轉為undefined，防止轉型失敗
 * optional: 過濾null、undefined、空字串
 * date_Validate: 日期相關的邏輯
 */

import { string, number, date, addMethod } from "yup";

// 驗證行動電話
addMethod(string, "mobile", function (errMsg) {
  return this.test({
    name: "mobile",
    message: errMsg || "請輸入行動電話",
    exclusive: false,
    test: (value) => {
      return optional(value) || /^09\d{8}$/.test(value);
    },
  });
});

// 驗證是否為Char
addMethod(string, "isChar", function (errMsg) {
  return this.test({
    name: "isChar",
    message: errMsg || "格式錯誤",
    test: (value) => {
      return optional(value) || /^[A-Za-z0-9]+$/.test(value);
    },
  });
});

// 驗證日期格式(YYYYMMDD)
addMethod(string, "dateformatvalid", function (errMsg) {
  return this.test({
    name: "dateformatvalid",
    message: errMsg || "請輸入有效的格式 (YYYYMMDD)",
    test: (value) => {
      if (optional(value)) {
        return true;
      }

      const y = parseInt(value?.substring(0, 4), 10);
      const m = parseInt(value?.substring(4, 6), 10);
      const d = parseInt(value?.substring(6, 8), 10);
      const limitInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      // 判斷是否為閏年
      const isLeap = new Date(y, 1, 29).getDate() === 29;

      if (isLeap) {
        limitInMonth[1] = 29;
      }

      let dateStr = y + "-" + m + "-" + d;
      dateStr = dateStr.replace(new RegExp(/-/gm), "/");
      const myDate = new Date(dateStr);
      return (
        !isNaN(myDate.getTime()) &&
        value?.length === 8 &&
        d <= limitInMonth[m - 1]
      );
    },
  });
});

// 檢核有效數字格式
addMethod(string, "validateNumber", function (errMsg) {
  return this.test({
    name: "validateNumber",
    message: errMsg || "請輸入有效數字格式",
    test: (value) => {
      return (
        optional(value) || /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(value)
      );
    },
  });
});

// 檢核英文字母
addMethod(string, "validateAlpha", function (errMsg) {
  return this.test({
    name: "validateAlpha",
    message: errMsg || "請輸入英文字母",
    test: (value) => {
      return optional(value) || /^[a-zA-Z]+$/.test(value);
    },
  });
});

// 檢核有效日期格式
addMethod(string, "validateDate", function (errMsg) {
  return this.test({
    name: "validateDate",
    message: errMsg || "請輸入有效日期格式",
    test: (value) => {
      if (optional(value)) {
        return true;
      }
      const test = new Date(value);
      return !isNaN(test);
    },
  });
});

// 檢核有效日期格式 YYYY-MM-DD
addMethod(string, "validateDateDb", function (errMsg) {
  return this.test({
    name: "validateDateDb",
    message: errMsg || "有效日期格式為: YYYY-MM-DD",
    test: (value) => {
      if (optional(value)) {
        return true;
      }
      const regex = /^(\d{4})\-(\d{2})\-(\d{2})$/;
      if (!regex.test(value)) {
        return false;
      }
      const d = new Date(value.replace(regex, "$1/$2/$3"));
      return (
        parseInt(RegExp.$2, 10) == 1 + d.getMonth() &&
        parseInt(RegExp.$3, 10) == d.getDate() &&
        parseInt(RegExp.$1, 10) == d.getFullYear()
      );
    },
  });
});

// 檢核正確的民國日期格式
addMethod(string, "validateROCDate", function (errMsg) {
  return this.test({
    name: "validateROCDate",
    message: errMsg || "請輸入正確的民國日期格式",
    test: (value) => {
      return optional(value) || date_Validate.isROCdate(value, false);
    },
  });
});

// 檢核正確之西元年月格式
addMethod(string, "validateDateYM", function (errMsg) {
  return this.test({
    name: "validateDateYM",
    message: errMsg || "請輸入正確之西元年月格式",
    test: (value) => {
      return optional(value) || date_Validate.isDateYM(value);
    },
  });
});

// 檢核正確之民國年月格式
addMethod(string, "validateROCDateYM", function (errMsg) {
  return this.test({
    name: "validateROCDateYM",
    message: errMsg || "請輸入正確之民國年月格式",
    test: (value) => {
      if (optional(value)) {
        return true;
      }
      return value.length < 6 ? date_Validate.isDateYM(value, true) : false;
    },
  });
});

// 檢核時分格式(HH:MM)(24小時制)
addMethod(string, "validateHHMM", function (errMsg) {
  return this.test({
    name: "validateHHMM",
    message: errMsg || "請輸入正確的24小時制時分格式 (HH:MM)",
    test: (value) => {
      if (optional(value)) {
        return true;
      }
      const times = value.split(":");
      if (times.length < 1) {
        //傳入值必須包含時跟分
        return false;
      }
      const h = times[0]; //小時
      const m = times[1]; //分
      if (optional(h) || isNaN(h) || h.length < 2 || h < 0 || h > 23) {
        return false;
      }
      if (optional(m) || isNaN(m) || m.length < 2 || m < 0 || m > 59) {
        return false;
      }
      return true;
    },
  });
});

// 檢核開始時間不得大於結束時間 (HH:MM)
addMethod(string, "validateHHMMMax", function (targetId, errMsg) {
  return this.test({
    name: "validateHHMMMax",
    message: errMsg || "開始時間不得大於結束時間",
    test: (value, context) => {
      const targetVal = context.parent?.[targetId];
      if (optional(value) && optional(targetVal)) {
        return true;
      }
      const str_time = value?.split(":") || [undefined, undefined];
      const end_time = targetVal?.split(":") || [undefined, undefined];

      return validateHourTime(str_time, end_time);
    },
  });
});

// 檢核結束時間不得小於開始時間 (HH:MM)
addMethod(string, "validateHHMMMin", function (targetId, errMsg) {
  return this.test({
    name: "validateHHMMMin",
    message: errMsg || "結束時間不得小於開始時間",
    test: (value, context) => {
      const targetVal = context.parent?.[targetId];
      if (optional(value) && optional(targetVal)) {
        return true;
      }
      const str_time = targetVal?.split(":") || [undefined, undefined];
      const end_time = value?.split(":") || [undefined, undefined];

      return validateHourTime(str_time, end_time);
    },
  });
});

/**
 * 檢核時間起迄提出重複邏輯
 * @param {string} str_time 開始時間(小時)
 * @param {string} end_time 結束時間(小時)
 * @returns {boolean} 是否通過檢核
 */
const validateHourTime = (str_time, end_time) => {
  const sH = str_time[0];
  const sM = str_time[1];
  const eH = end_time[0];
  const eM = end_time[1];

  // 判斷是否為沒有輸入值或是格式錯誤
  const isIllegalStr_H = optional(sH) || isNaN(sH) || sH.length < 2;
  const isIllegalStr_M = optional(sM) || isNaN(sM) || sM.length < 2;
  const isIllegalEnd_H = optional(eH) || isNaN(eH) || eH.length < 2;
  const isIllegalEnd_M = optional(eM) || isNaN(eM) || eM.length < 2;

  if (isIllegalStr_H || isIllegalStr_M || isIllegalEnd_H || isIllegalEnd_M) {
    return false;
  }

  //起始小時>結束小時 OR 起時小時 = 結束小時但起始分鐘 > 結束分鐘
  if (sH > eH || (sH == eH && sM > eM)) {
    return false;
  }

  return true;
};

// 檢核民國起日不得大於迄日
addMethod(string, "validateROCDateMax", function (targetId, errMsg) {
  return this.test({
    name: "validateROCDateMax",
    message: errMsg || "民國起日不得大於迄日",
    test: (value, context) => {
      const targetVal = context.parent?.[targetId];
      if (optional(value) && optional(targetVal)) {
        return true;
      }
      return date_Validate.diffDayROC(value, targetVal) >= 0;
    },
  });
});

// 檢核民國迄日不得小於起日
addMethod(string, "validateROCDateMin", function (targetId, errMsg) {
  return this.test({
    name: "validateROCDateMin",
    message: errMsg || "民國迄日不得小於起日",
    test: (value, context) => {
      const targetVal = context.parent?.[targetId];
      if (optional(value) && optional(targetVal)) {
        return true;
      }
      return date_Validate.diffDayROC(value, targetVal) <= 0;
    },
  });
});

// 身分證檢核
addMethod(string, "validatorROCID", function (errMsg) {
  return this.test({
    name: "validatorROCID",
    message: errMsg || "請輸入正確的身分證",
    test: (value) => {
      const ROCID = value?.replace(/\s+/g, "");
      return optional(value) || /^[A-Z]{1}[1-2]{1}[0-9]{8}$/.test(ROCID);
    },
  });
});

// 居留證檢核
addMethod(string, "validatorResidentID", function (errMsg) {
  return this.test({
    name: "validatorResidentID",
    message: errMsg || "請輸入正確的居留證",
    test: (value) => {
      const ResidentID = value?.replace(/\s+/g, "");
      return optional(value) || /^[A-Z]{1}[A-D]{1}[0-9]{8}$/.test(ResidentID);
    },
  });
});

/**
 * 防止number, date判斷檢核時發生資料型別的問題, 例如"空字串"不為number或date, 但使用者依然可以使input欄位為空
 * @param {*} value 傳入值
 * @returns {*} 原值或undefined
 */
const skipEmptyStr = (value) => (isNaN(value) ? undefined : value);
addMethod(date, "skipEmptyStr", function () {
  return this.transform(skipEmptyStr);
});

addMethod(number, "skipEmptyStr", function () {
  return this.transform(skipEmptyStr);
});

// -----------private的檢核方法----------------------------------------------

/**
 *	標註為不需要；若傳入undefined、null或空字串，不會使驗證失敗
 *	@param {*} val 傳入值
 *	@returns {boolean} 檢核結果
 *	@author 張立賢
 *	@version 1.0.0
 */
const optional = (val) => {
  const checkUndefined = typeof val === "undefined";
  const checkString = typeof val === "string" && val === "";

  return checkUndefined || checkString || val === null;
};

/**
 * 程式：date.js日期相關js。
 *
 * 功能：提供日期相關js。
 */
const date_Validate = {
  /**
   *	轉為日期物件
   *	@param {string} srcData 民國日期
   *	@param {boolean} isROCBefore 是否為民國年前，若輸入參數為民國前，請傳入 true ，預設為 false。
   *	@returns {Date} 回傳值
   *	@author 劉本傑
   *	@version 1.0.0
   */
  stringToDate_ROC: (srcData, isROCBefore) => {
    let rocDateIsBefore = 1;
    let mySrcData = srcData;

    if (isROCBefore) {
      if (mySrcData.substring(0, 1) == "-") {
        mySrcData = mySrcData.substring(1, mySrcData.length);
        rocDateIsBefore = -1;
      }
    }
    let d;
    if (
      mySrcData.match(/^(\d{1})(\d{2})(\d{2})$/) ||
      mySrcData.match(/^(\d{2})(\d{2})(\d{2})$/) ||
      mySrcData.match(/^(\d{3})(\d{2})(\d{2})$/) ||
      mySrcData.match(/^(\d{1})\/(\d{2})\/(\d{2})$/) ||
      mySrcData.match(/^(\d{2})\/(\d{2})\/(\d{2})$/) ||
      mySrcData.match(/^(\d{3})\/(\d{2})\/(\d{2})$/) ||
      mySrcData.match(/^(\d{1})\-(\d{2})\-(\d{2})$/) ||
      mySrcData.match(/^(\d{2})\-(\d{2})\-(\d{2})$/) ||
      mySrcData.match(/^(\d{3})\-(\d{2})\-(\d{2})$/)
    ) {
      d = new Date(
        rocDateIsBefore * parseInt(RegExp.$1, 10) + 1911,
        parseInt(RegExp.$2, 10) - 1,
        parseInt(RegExp.$3, 10),
      );
    }
    return d;
  },
  /**
   * check ROC date format, 4 pattern can be accepted 「yyMMDD, yy/MM/DD, yyy-MM-DD, yyyMMDD, yyy/MM/DD, yyy-MM-DD」
   * + 若限制在 20 年以前（不含）時，在西元 1911-01-01（民國 000101）會視為合理日期。
   * + 若為民國前之年月日時，會在日期前加上 - ，如 民國前 1 年 2 月 3 日為 -000203，民國前 2 年 2 月 3 日為 -010203。
   *   + isROCdate('191231')                 return  false。
   *   + isROCdate('191231', false)          return  true 。
   *   + isROCdate('-010203', false)         return  false。
   *   + isROCdate('-010203', false, true)   return  true 。
   *   + isROCdate('1000203')                return  true 。
   *   + isROCdate('200/01/01')              return  true 。
   *   + isROCdate('100-10-28')              return  true 。
   * @param {string} srcData 民國年月日
   * @param {boolean} yearLimit 民國年是否限制在 20 年以前（不含），若不限制，請傳入 false，預設為限制
   * @param {boolean} isROCBefore 是否為民國年前，若輸入參數為民國前，請傳入 true ，預設為 false
   * @returns {boolean} 檢核結果
   */
  isROCdate: (srcData, yearLimit, isROCBefore) => {
    const d = date_Validate.stringToDate_ROC(srcData, isROCBefore);

    if (!d || d.getMonth() != RegExp.$2 - 1 || d.getDate() != RegExp.$3) {
      return false;
    }

    if (yearLimit !== false) {
      /*
        西元 1931 年以前（不含）或民國 20 年以前（不含）算是不正確之日期格式
        西元 1911-01-01（民國 000101）視為合理日期
        Date getMonth() - Returns the month from the date object as a value from 0 through 11.
        Date getDate() - Get the day of the month. It is returned as a value between 1 and 31.
      */
      if (
        !(d.getFullYear() == 1911 && d.getMonth() == 0 && d.getDate() == 1) &&
        d.getFullYear() < 1931
      ) {
        return false;
      }
    }
    return true;
  },
  isDateYM: (srcDate, isROC) => {
    const reg = isROC
      ? new RegExp(/^(\d{2,3})(0[1-9]|1[0-2])$/)
      : new RegExp(/^(\d{4})(0[1-9]|1[0-2])$/);
    return reg.test(srcDate);
  },
  /**
   * 計算二民國日期相差天數之方法（日期2-日期1）。
   * + diffDayROC('990901', '990901') return   0。
   * + diffDayROC('990901', '990903') return   2。
   * + diffDayROC('990901', '990820') return -12。
   * + diffDayROC('-11231', '000113') return  13。
   * @param {string} strRoc1 民國日期1
   * @param {string} strRoc2 民國日期2
   * @returns {string} 相差天數
   */
  diffDayROC: (strRoc1 = "", strRoc2 = "") => {
    const dateInt1 = date_Validate.stringToDate_ROC(strRoc1, true);
    const dateInt2 = date_Validate.stringToDate_ROC(strRoc2, true);
    return (dateInt2 - dateInt1) / 86400000;
  },
};
