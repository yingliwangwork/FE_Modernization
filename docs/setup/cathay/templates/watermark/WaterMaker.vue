<template>
  <div></div>
</template>
<script setup>
import { ref, watch, onMounted, onBeforeUnmount } from "vue";
import propsDef from "./modules/WaterMaker.js";
import dayjs from "dayjs";

const props = defineProps(propsDef);

onMounted(() => {
    // 確認DOM物件生成後，再執行渲染浮水印
    if (props.show && props.defaultDisplay) {
        init();
    }
    if (props.inputAllowDele) {
        Monitor();
    }
});

const textArray = ref([
    {
        inputText: "內部畫面 嚴禁外流",
        x: 220,
        y: 200,
    },
    {
        inputText: "查獲屬實送人管單位處分",
        x: 220,
        y: 250,
    },
    { inputText: dayjs().format("YYYY-MM-DD HH:mm:ss"), x: 220, y: 300 },
]);
if (props.inputText) {
    textArray.value.unshift({ inputText: props.inputText, x: 210, y: 150 });
}

const maskDiv = ref(null);
/**
 * 初始化
*/
const init = () => {
    const canvas = document.createElement("canvas");
    canvas.id = "canvas";
    canvas.width = props.width;
    canvas.height = props.height;

    maskDiv.value = document.createElement("div");
    const ctx = canvas.getContext("2d");
    ctx.font = props.fontStyle;

    ctx.fillStyle = "rgba(0, 0, 0, 0.07)"; //水印字體顏色
    ctx.rotate((-20 * Math.PI) / 180); //水印偏轉角度
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";

    textArray.value.forEach((text) => {
        ctx.fillText(text.inputText, text.x, text.y);
    });

    const src = canvas.toDataURL("image/png");
    maskDiv.value.style.position = "fixed";
    maskDiv.value.style.zIndex = "9999";
    maskDiv.value.id = "_waterMark";
    maskDiv.value.style.top = "0";
    maskDiv.value.style.left = "-20px";
    maskDiv.value.style.width = "100%";
    maskDiv.value.style.height = "100%";
    maskDiv.value.style.pointerEvents = "none";
    maskDiv.value.style.backgroundImage = "URL(" + src + ")";
    maskDiv.value.alive = true;

    document.body.appendChild(maskDiv.value);
};

watch(
    () => props.show,
    (newVal) => {
        if (newVal === true || (newVal === undefined && props.defaultDisplay)) {
        createMaskDiv();
        } else {
        removeMaskDiv();
        }
    },
);

/**
 * 刪除浮水印DOM
*/
const removeMaskDiv = () => {
if (maskDiv.value.id && maskDiv.value.alive) {
    document.body.removeChild(maskDiv.value);
    maskDiv.value.alive = false;
}
};

/**
 * 生成浮水印
*/
const createMaskDiv = () => {
if (!maskDiv.value?.alive) {
    init();
}
};

/**
 * 浮水印監聽事件
*/
const Monitor = () => {
const body = document.getElementsByTagName("body")[0];
const options = {
    childList: true,
    attributes: true,
    characterData: true,
    subtree: true,
    attributeOldValue: true,
    characterDataOldValue: true,
};
const observer = new MutationObserver(callback);
observer.observe(body, options); // 掛載監聽
};

/**
 * callback
* @param {Array} mutations - mutations
*/
const callback = (mutations) => {
    // 當attribute被改變時
    if (mutations[0].target.id === "_waterMark") {
        removeMaskDiv();
    }

    // 當節點被刪除時
    if (
        mutations[0].removedNodes[0] &&
        mutations[0].removedNodes[0].id === "_waterMark"
    ) {
        init();
    }
};

// 該元件結束生命週期時，必須移除浮水印以及相關監控，否則會發生重疊
onBeforeUnmount(() => {
    removeMaskDiv();
    observer.disconnect();
});
</script>