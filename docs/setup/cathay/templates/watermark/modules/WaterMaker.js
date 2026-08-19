export default {
    show: {
        type: Boolean,
        default: true,
    },
    defaultDisplay: {
        type: Boolean,
        default: true,
    },
    fontStyle: {
        type: String,
        default: "28px Microsoft Yahei",
    },
    // 浮水印高度
    width: {
        type: Number,
        default: 700,
    },
    // 浮水印寬度
    height: {
        type: Number,
        default: 300,
    },
    // 顯示浮水印內容
    inputText: {
        type: String,
        default: "",
    },
    // 是否監控DOM物件變化，避免使用各種方式修改浮水印節點。
    // true為監控，預設監控
    inputAllowDele: {
        type: Boolean,
        default: true,
    },
};