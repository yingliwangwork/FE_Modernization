/**
 * 共用工具函式集：身分證／統一編號驗證、民國西元日期互換、姓名遮蔽等
 * 使用方式：const { checkROCID, formatDate, ... } = useCommonUtil()
 */
export default function () {
  /*「統一編號」相關 */

  // 營業人統一編號八碼各自的乘數
  const uniSNMultiple = [1, 2, 1, 2, 1, 2, 4, 1];

  /*「國民身份證統一編號、居留證檢查」相關 */

  // 正常的字母順序表
  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  // 依公佈之字母對應數值，個位數乘以 9 加上十位數後，除以 10 所得之餘數的對應表
  const modInt = [
    1, 0, 9, 8, 7, 6, 5, 4, 9, 3, 2, 2, 1, 0, 8, 9, 8, 7, 6, 5, 4, 3, 1, 3, 2,
    0,
  ];

  // 公佈之字母對應數值之個位數對應表
  const digitInt = [
    0, 1, 2, 3, 4, 5, 6, 7, 4, 8, 9, 0, 1, 2, 5, 3, 4, 5, 6, 7, 8, 9, 2, 0, 1,
    3,
  ];

  // 驗証時各指定的乘數
  const mulInt = [1, 8, 7, 6, 5, 4, 3, 2, 1];

  const convertNumMapping = "PDKOAFNCLJQRMBEGHSIX";

  //2020-04-09 配合移民署政策
  //新制各字母對應之數字
  const alphabetMappingDigit = [
    10, 11, 12, 13, 14, 15, 16, 17, 34, 18, 19, 20, 21, 22, 35, 23, 24, 25, 26,
    27, 28, 29, 32, 30, 31, 33,
  ];

  //2020-04-09 配合移民署政策
  //新制驗証時各指定的乘數
  const mulIntNew = [1, 9, 8, 7, 6, 5, 4, 3, 2, 1];

  /**
   * 檢核中華民國身份證字號是否合法
   * @param {string} ID 中華民國身份證字號
   * @returns {boolean} true: 合法 false: 不合法
   */
  function checkROCID(ID) {
    // 輸入參數不可為空值且長度共 10 碼
    if (typeof ID == "undefined" || ID == null || ID == "" || ID.length != 10) {
      return false;
    }

    ID = convertCheckId(ID);
    if (ID === null) {
      return true;
    }

    const letterIndex = alphabet.indexOf(ID.charAt(0));

    if (letterIndex == -1) {
      return false;
    }

    //2020-04-10 配合移民署政策
    if ("89".indexOf(ID.charAt(1)) >= 0) {
      return false;
    }

    const intNum = modInt[letterIndex];

    const tmpStr = "" + intNum + ID.substring(1, 10);

    return checkSum(ID, tmpStr);
  }

  /**
   * 檢核中華民國護照號碼是否合法
   * @param {string} ID 中華民國護照號碼
   * @returns {boolean} true: 合法 false: 不合法
   */
  function checkROCPassport(ID) {
    // 第2碼性別碼
    return "12".indexOf(ID.substring(1, 2)) >= 0;
  }

  /**
   * 檢核中華民國無戶籍人民身份證號（居留證）是否合法
   * @param {string} ID 居留證號
   * @returns {boolean} true: 合法 false: 不合法
   */
  function checkROCARC(ID) {
    // 輸入參數不可為空值且長度共 10 碼
    if (typeof ID == "undefined" || ID == null || ID == "" || ID.length != 10) {
      return false;
    }

    ID = convertCheckId(ID);
    if (ID === null) {
      return true;
    }

    const letterIndex = alphabet.indexOf(ID.charAt(0));
    const secondIndex = alphabet.indexOf(ID.charAt(1));
    // 2020-04-10 配合移民署政策
    const newRuleSecondIndex = "89".indexOf(ID.charAt(1));

    if (letterIndex == -1 || (secondIndex == -1 && newRuleSecondIndex == -1)) {
      return false;
    }

    let tmpStr = "";
    // 轉換為數列
    if (newRuleSecondIndex != -1) {
      const intNum = alphabetMappingDigit[letterIndex];
      tmpStr = "" + intNum + ID.substring(1, 10);
    } else {
      const intNum = modInt[letterIndex];
      const intNum2 = digitInt[secondIndex];
      tmpStr = "" + intNum + intNum2 + ID.substring(2, 10);
    }
    return checkSum(ID, tmpStr);
  }

  /**
   * 檢核營業人統一編號是否合法
   * @param {string} UniSN 統一編號
   * @returns {boolean} true: 合法 false: 不合法
   */
  function checkUniSN(UniSN) {
    // 輸入參數不可為空值且長度共 8 位
    if (
      typeof UniSN == "undefined" ||
      UniSN == null ||
      UniSN == "" ||
      UniSN.length != 8
    ) {
      return false;
    }

    // 組成驗證用的號碼字串
    let intValue = 0;

    // 傳入參數的第 7 碼的數字是否為 7
    let position7Is7 = false;

    for (let i = 0; i < UniSN.length; i++) {
      const strTempCharAt = UniSN.charAt(i);
      const num = parseInt(strTempCharAt, 10);

      // 判斷第 7 碼的數字是否為 7
      if (i == 6 && num == 7) {
        position7Is7 = true;
      }

      // 每個數字  × 乘數
      const multiplyNumber = num * uniSNMultiple[i];

      // 取得個位數（即 10 的餘數）
      const remainderByTen = multiplyNumber % 10;

      intValue += remainderByTen;

      // 取得十位數
      intValue += (multiplyNumber - remainderByTen) / 10;
    }

    // 若能被  5 整除，表示營業人統一編號正確
    let isValidate = intValue % 5 == 0;
    if (!isValidate && position7Is7) {
      intValue += 1;
      isValidate = intValue % 5 == 0;
    }

    return isValidate;
  }
  /**
   * 計算國民身份証、居留證、旅行證號是否符合邏輯
   * @param {string} id 證件號碼
   * @param {string} tmpStr
   * @returns {boolean} true: 合法 false: 不合法
   */
  function checkSum(id, tmpStr) {
    const lastChar = id.charAt(id.length - 1);
    if (isNaN(lastChar)) {
      return false;
    }

    //最後一碼為檢查碼
    const chkCode = parseInt(lastChar, 10);
    let sum = 0;
    //2020-04-10 配合移民署政策
    if ("89".indexOf(id.charAt(1)) != -1) {
      //依各乘數計算和
      for (let i = 0; i < 10; i++) {
        const currChar = tmpStr.charAt(i);
        if (isNaN(currChar)) {
          return false;
        }
        sum += (parseInt(currChar, 10) * mulIntNew[i]) % 10;
      }
    } else {
      //依各乘數計算和
      for (let i = 0; i < 9; i++) {
        const currChar = tmpStr.charAt(i);
        if (isNaN(currChar)) {
          return false;
        }
        sum += parseInt(currChar, 10) * mulInt[i];
      }
    }

    //取餘數
    const mod = sum % 10;

    //驗証補數
    return (mod == 0 && chkCode == 0) || mod + chkCode == 10;
  }

  function convertCheckId(inputId) {
    inputId = inputId.toUpperCase();
    const lastWrodIndex = inputId.length - 1;
    const lastWord = inputId.charAt(lastWrodIndex);
    const num = convertNumMapping.indexOf(lastWord);
    if (num >= 0) {
      return null;
    }
    return inputId;
  }

  /**
   * 由證號取得性別
   * @param {string} type 證件類別 1: 國民身份證 2: 居留證號
   * @param {string} id 證件號碼
   * @returns {string} SEX 性別 1: 男 2: 女 空白: Error
   */
  function getSex(type, id) {
    if (id.length != 10) {
      return "";
    }

    let SEX = "";
    const idArr = id.split("");

    if ("1" == type) {
      /*國民身份證*/
      if ("1" == idArr[1] || "2" == idArr[1]) {
        SEX = idArr[1];
      }
    } else if ("2" == type) {
      /*居留證號*/
      if ("8" == idArr[1] || "A" == idArr[1] || "C" == idArr[1]) {
        SEX = "1";
      } else if ("9" == idArr[1] || "B" == idArr[1] || "D" == idArr[1]) {
        SEX = "2";
      }
    }
    return SEX;
  }

  /**
   * 將 YYYYMMDD 格式日期轉為 YYYY-MM-DD
   * @param {string} inputDate 輸入日期 (ex: YYYYMMDD)
   * @param {*} [mark] 未使用，保留參數位置供相容呼叫
   * @returns {string} outputDate 輸出日期 YYYY-MM-DD
   */
  function formatToDate(inputDate, mark) {
    let outputDate = "";
    if (undefined != inputDate) {
      if (inputDate != "" && inputDate.length == 8) {
        const year = inputDate.substring(0, 4);
        const month = inputDate.substring(4, 6);
        const day = inputDate.substring(6, 8);
        outputDate = year + "-" + month + "-" + day;
      }
    }
    return outputDate;
  }

  /**
   * 計算年齡
   * @param {string} date 日期 (YYYY-MM-DD)
   * @param {string} birthday 生日 (YYYY-MM-DD)
   * @param {boolean} [ceDateWithoutDash] 傳入日期是否為無分隔線的西元格式 (YYYYMMDD)
   * @returns {string} age 年齡
   */
  function calAge(date, birthday, ceDateWithoutDash) {
    let issueDayTime;
    let birthDayTime;

    if (ceDateWithoutDash) {
      issueDayTime = new Date(formatToDate(date, ""));
      birthDayTime = new Date(formatToDate(birthday, ""));
    } else {
      issueDayTime = new Date(date);
      birthDayTime = new Date(birthday);
    }

    const age =
      issueDayTime.getFullYear() -
      birthDayTime.getFullYear() -
      (issueDayTime.getMonth() < birthDayTime.getMonth() ||
      (issueDayTime.getMonth() == birthDayTime.getMonth() &&
        issueDayTime.getDate() < birthDayTime.getDate())
        ? 1
        : 0);

    return age;
  }

  /**
   * 找 FieldOption 對應的 Label by Value
   * @param {string} inputValue Field Option 的 Value
   * @param {object} inputObj FieldOption Obj.
   * @returns {string} Field Option 的 Value 對應的 Label
   */
  function getLabelByKey(inputValue, inputObj) {
    let result = "";
    Object.entries(inputObj).forEach(([key, value]) => {
      if (value.value == inputValue) {
        result = value.label;
      }
    });
    return result;
  }

  /**
   * 找 FieldOption 對應的 Value by Label
   * @param {string} inputValue Field Option 的 Label
   * @param {object} inputObj FieldOption Obj.
   * @returns {string} Field Option 的 Label 對應的 Value
   */
  function getValueByLabel(inputValue, inputObj) {
    let result = "";
    Object.entries(inputObj).forEach(([key, value]) => {
      if (value.label == inputValue) {
        result = value.value;
      }
    });
    return result;
  }

  /**
   * 找 FieldOption 對應的 Value 是否存在
   * @param {string} inputValue Field Option 的 Label
   * @param {object} inputObj FieldOption Obj.
   * @returns {string} Field Option 的 Label 對應的 Value
   */
  function checkValueExist(inputValue, inputObj) {
    let result = "";
    Object.entries(inputObj).forEach(([key, value]) => {
      if (value == inputValue) {
        result = value;
      }
    });
    return result;
  }

  /**
   * 西元日期和民國日期互換套件 (轉換失敗則回傳原本日期不作變動)
   * @param {string} date 西元(YYYY-MM-DD)或民國(YYY-MM-DD/YY-MM-DD)日期
   * @param {string} result rocDate 西元轉民國日期 ceDate 民國轉西元日期 ceDateWithoutDash 民國轉西元日期
   * @returns {string} date 轉換後之日期
   */
  function tranCEorROCDate(date, result) {
    let year = 0;
    let month = 0;
    let day = 0;

    if ("ceDate" == result || "ceDateWithoutDash" == result) {
      // 民國轉西元
      // 判斷是否合法民國日期
      if (!isValidROCDate(date)) {
        return date;
      }

      if (date.length == 6) {
        year = parseInt(date.substring(0, 2), 10) + 1911;
        month = parseInt(date.substring(2, 4), 10);
        day = parseInt(date.substring(4, 6), 10);
      } else if (date.length == 7) {
        year = parseInt(date.substring(0, 3), 10) + 1911;
        month = parseInt(date.substring(3, 5), 10);
        day = parseInt(date.substring(5, 7), 10);
      }

      if ("ceDateWithoutDash" == result) {
        return formatDate(year + "-" + month + "-" + day, false);
      }
      return formatDate(year + "-" + month + "-" + day, true);
    }
    if ("rocDate" == result) {
      // 西元轉民國
      // 判斷是否合法西元日期
      if (!isValidDate(date, false)) {
        return date;
      }

      const parts = date.split("-");
      year = parseInt(parts[0], 10) - 1911;
      month = parseInt(parts[1], 10);
      day = parseInt(parts[2], 10);
      return (
        getZeroFill(year.toString(), 3) +
        getZeroFill(month.toString(), 2) +
        getZeroFill(day.toString(), 2)
      );
    }

    return date;
  }

  /**
   * 補零
   * @param {string} num 輸入數字
   * @param {string} digit 位數(2or3)
   * @returns {string} num (2 -> 02, 86 -> 086)
   */
  function getZeroFill(num, digit) {
    if (2 == digit) {
      if (parseInt(num, 10) < 10) {
        num = "0" + num;
      }
    } else if (3 == digit) {
      if (parseInt(num, 10) < 100) {
        num = "0" + num;
      }
    }
    return num;
  }

  /**
   * 轉換日期並補零
   * @param {string} date 西元日期 (YYYY-M-D)
   * @param {boolean} withDash ture 輸出格式為"YYYY-MM-DD" false 輸出格式為"YYYYMMDD"
   * @returns {string} oTime 西元日期 (YYYY-MM-DD/YYYYMMDD)
   */
  function formatDate(date, withDash) {
    const oDate = new Date(date);
    const oYear = oDate.getFullYear();
    const oMonth = oDate.getMonth() + 1;
    const oDay = oDate.getDate();

    let oTime = "";
    if (withDash) {
      oTime =
        oYear +
        "-" +
        getZeroFill(oMonth.toString(), 2) +
        "-" +
        getZeroFill(oDay.toString(), 2);
    } else {
      oTime =
        oYear +
        getZeroFill(oMonth.toString(), 2) +
        getZeroFill(oDay.toString(), 2);
    }

    return oTime;
  }

  /**
   * 判斷是否為合法之西元日期格式
   * @param {string} date 西元日期 (YYYY-MM-DD/YYYYMMDD)
   * @param {boolean} withDash ture 輸入格式為"YYYY-MM-DD" false 輸入格式為"YYYYMMDD"
   * @returns {boolean} true 合法 false 不合法
   */
  function isValidDate(date, withDash) {
    let year = NaN;
    let month = NaN;
    let day = NaN;

    if (withDash) {
      const parts = date.split("-");
      if (parts.length < 3) {
        return false;
      }
      year = parseInt(parts[0], 10);
      month = parseInt(parts[1], 10);
      day = parseInt(parts[2], 10);
    } else {
      year = parseInt(date.substring(0, 4), 10);
      month = parseInt(date.substring(4, 6), 10);
      day = parseInt(date.substring(6, 8), 10);
    }

    if (isNaN(day) || isNaN(month) || isNaN(year)) {
      return false;
    }
    if (day < 1 || year < 1) return false;
    if (month > 12 || month < 1) return false;
    if (
      (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 12) &&
      day > 31
    ) {
      return false;
    }
    if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) {
      return false;
    }
    if (month == 2) {
      if (
        (year % 4 == 0 && year % 100 != 0) ||
        (year % 400 == 0 && year % 100 == 0)
      ) {
        if (day > 29) return false;
      } else if (day > 28) return false;
    }
    return true;
  }

  /**
   * 判斷是否為合法之民國日期格式 (轉換成西元日期再判斷)
   * @param {string} date 民國(YYY-MM-DD/YY-MM-DD)日期
   * @returns {boolean} true 合法 false 不合法
   */
  function isValidROCDate(date) {
    if (date.length == 6 || date.length == 7) {
      let year = 0;
      let month = 0;
      let day = 0;

      if (date.length == 6) {
        year = parseInt(date.substring(0, 2), 10) + 1911;
        month = parseInt(date.substring(2, 4), 10);
        day = parseInt(date.substring(4, 6), 10);
      } else if (date.length == 7) {
        year = parseInt(date.substring(0, 3), 10) + 1911;
        month = parseInt(date.substring(3, 5), 10);
        day = parseInt(date.substring(5, 7), 10);
      } else {
        return false;
      }

      return isValidDate(
        formatDate(year + "-" + month + "-" + day, true),
        true,
      );
    }
  }

  /**
   * 取現在日期
   * @param {boolean} withDash ture 輸出格式為"YYYY-MM-DD" false 輸出格式為"YYYYMMDD"
   * @returns {string} date
   */
  function getNowDate(withDash) {
    const nowDay = new Date();
    const DD = String(nowDay.getDate()).padStart(2, "0");
    const MM = String(nowDay.getMonth() + 1).padStart(2, "0");
    const YYYY = nowDay.getFullYear();

    if (withDash) {
      return YYYY + "-" + MM + "-" + DD;
    }
    return YYYY + MM + DD;
  }

  /**
   * 取現在時間
   * @param {number} addHours 加多少個小時
   * @returns {string} time
   */
  function getNowTime(addHours) {
    const tempDate = new Date();
    tempDate.setHours(tempDate.getHours() + addHours);

    return (
      tempDate.getHours().toString().padStart(2, "0") +
      ":" +
      tempDate.getMinutes().toString().padStart(2, "0") +
      ":" +
      tempDate.getSeconds().toString().padStart(2, "0")
    );
  }

  /**
   * 轉換國籍 例子: TW -> 7
   * @param {string} national 輸入國籍 (ex: TW)
   * @returns {string} resultNational 輸出國籍 7
   */
  function transNational(national) {
    let resultNational = "7";
    if ("TW" == national) {
      resultNational = "7";
    } else if ("US" == national) {
      resultNational = "1";
    } else if ("CA" == national) {
      resultNational = "2";
    } else if ("JP" == national) {
      resultNational = "3";
    } else if ("TH" == national) {
      resultNational = "4";
    } else if ("GB" == national) {
      resultNational = "5";
    } else if ("CN" == national) {
      resultNational = "6";
    } else if ("XX" == national) {
      resultNational = "8";
    } else if ("" == national) {
      resultNational = "7";
    } else if (!isNaN(parseInt(national, 10))) {
      resultNational = national;
    } else {
      resultNational = "8";
    }
    return resultNational;
  }

  /**
   * 姓名資料遮蔽
   * 遮蔽方式：以＊取代第一個字與最後一個字之間的文字
   * 若僅傳入一個字，以＊新增至最後一個字
   * 若僅傳入二個字，以＊最後一個字之間的文字
   * @param {string} name 姓名
   * @returns {string} 遮蔽姓名
   */
  function getMaskName(name) {
    const nameSplit = name.replace(" ", "").split("");

    if (1 == nameSplit.length) {
      nameSplit.push("＊");
    } else if (2 == nameSplit.length) {
      nameSplit[1] = "＊";
    } else if (3 == nameSplit.length) {
      nameSplit[1] = "＊";
    } else {
      for (let i = 0; i < nameSplit.length; i++) {
        if (i > 1 && i < nameSplit.length - 1) {
          nameSplit[i] = "＊";
        }
      }
    }

    return nameSplit.join("");
  }

  return {
    checkROCID,
    checkROCPassport,
    checkROCARC,
    checkUniSN,
    getSex,
    calAge,
    getLabelByKey,
    getValueByLabel,
    checkValueExist,
    isValidDate,
    isValidROCDate,
    formatDate,
    tranCEorROCDate,
    getNowDate,
    getNowTime,
    formatToDate,
    transNational,
    getMaskName,
  };
}
