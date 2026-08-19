/**
 * 網頁防護浮水印模組
 */

// 1. 全局配置變數
const config = {
    text: '浮水印範例文字',
    // Canvas 畫布與文字設定
    canvas: {
        width: 700,
        height: 300,
        rotate: -20, // 旋轉角度 (度)
        font: '28px "Microsoft Yahei"',
        fillStyle: 'rgba(0, 0, 0, 0.07)',
        textAlign: 'center',
        textBaseline: 'middle',
        x: 220,  // 文字 X 軸起點
        y: 200  // 文字 Y 軸起點
    },
    // 最外層容器樣式
    style: `
        position: fixed !important;
        top: 0 !important;
        left: -20px !important;
        width: 100% !important;
        height: 100% !important;
        z-index: 9999 !important;
        pointer-events: none !important;
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
        background-repeat: repeat !important;
    `
};

// 內部狀態變數
let watermarkWrapper = null;
let observerInstance = null;
let intervalId = null;

/**
 * 生成浮水印的 Canvas 背景圖片
 * @returns {string} base64 圖片字串
 */
const createWatermarkBase64 = () => {
    const canvas = document.createElement('canvas');
    canvas.width = config.canvas.width;
    canvas.height = config.canvas.height;

    const ctx = canvas.getContext('2d');
    ctx.rotate((config.canvas.rotate * Math.PI) / 180);
    ctx.font = config.canvas.font;
    ctx.fillStyle = config.canvas.fillStyle;
    ctx.textAlign = config.canvas.textAlign;
    ctx.textBaseline = config.canvas.textBaseline;
    ctx.fillText(config.text, config.canvas.x, config.canvas.y);

    return canvas.toDataURL('image/png');
};

/**
 * 建立並插入浮水印節點
 */
const initWatermark = () => {
    if (watermarkWrapper) watermarkWrapper.remove();

    const base64 = createWatermarkBase64();
    watermarkWrapper = document.createElement('div');
    watermarkWrapper.id = 'system-safe-guard';

    // 使用 Shadow DOM 防禦
    const shadow = watermarkWrapper.attachShadow({ mode: 'open' });
    const watermarkInner = document.createElement('div');

    // 組合全局樣式與動態背景
    watermarkInner.setAttribute('style', `${config.style} background-image: url(${base64}) !important;`);
    shadow.appendChild(watermarkInner);

    document.body.appendChild(watermarkWrapper);
};

/**
 * 監聽防竄改行為
 */
const startObserve = () => {
    if (observerInstance) observerInstance.disconnect();

    observerInstance = new MutationObserver((mutations) => {
        for (const mutation of mutations) {
            const isRemoved = Array.from(mutation.removedNodes).includes(watermarkWrapper);
            const isModified = mutation.target === watermarkWrapper || mutation.target.parentNode === watermarkWrapper;

            if (isRemoved || (mutation.type === 'attributes' && isModified)) {
                observerInstance.disconnect();
                initWatermark();
                startObserve();
                break;
            }
        }
    });

    observerInstance.observe(document.body, {
        attributes: true,
        childList: true,
        subtree: true,
        attributeFilter: ['style', 'id', 'class']
    });
};

/**
 * 外部呼叫的主啟動函式
 * @param {string} [text] - 可選，動態覆蓋預設浮水印文字
 */
const setWatermark = (text) => {
    if (typeof window === 'undefined' || !document.body) return;

    if (text) config.text = text;

    initWatermark();
    startObserve();

    // 定時器雙重檢查
    if (intervalId) clearInterval(intervalId);
    intervalId = setInterval(() => {
        if (!document.getElementById('system-safe-guard')) {
            initWatermark();
            startObserve();
        }
    }, 2000);
};

export { setWatermark };
