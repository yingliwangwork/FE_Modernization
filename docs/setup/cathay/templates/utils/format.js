/**
 * 在千位數字前添加逗號
 * @param {number} num – 要添加逗號的數字
 * @returns {string} 在千位數字前添加逗號的數字
 * @example
 * numberAddComma(1000) // 回傳 "1,000"
 * numberAddComma(1200304050) // 回傳
 */
export const numberAddComma = (num) => {
  if (!num && num !== 0) {
    return "";
  }
  const comma = /\B(?=(\d{3})+(?!\d))/g;
  return num.toString().replace(comma, ",");
};

/**
 * 姓名遮蔽規則
 * 第一和最後一個字不遮，中間文字遮蔽成＊
 * 若姓名僅有兩個字，則第一個字不遮、第二個字遮蔽成＊
 * @param {string} str – 要遮蔽的字串
 * @returns {string} 遮蔽後的字串
 */
export const maskName = (str) => {
  // 如果字串長度為2，僅遮蔽第二個字
  if (str.length === 2) {
    return `${str[0]}*`;
  }

  // 如果字串長度大於2，則遮蔽中間的所有字元
  if (str.length > 2) {
    const firstChar = str[0]; // 第一個字
    const lastChar = str[str.length - 1]; // 最後一個字
    const maskedPart = "*".repeat(str.length - 2); // 中間的字全部替換為*
    return `${firstChar}${maskedPart}${lastChar}`;
  }

  // 如果字串長度小於2，直接返回原字串（無需遮蔽）
  return str;
};

/**
 * 地址遮蔽規則
 * 阿拉伯數字不分全形、半形皆遮蔽成＊
 * @param {string} address – 要遮蔽的地址字串
 * @returns {string} 遮蔽後的地址字串
 */
export const maskAddress = (address) => {
  // 匹配所有阿拉伯數字（全形和半形）
  return address.replace(/[\d０-９]/g, "*");
};
