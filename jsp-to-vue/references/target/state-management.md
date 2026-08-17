# 狀態管理規範

## 本地狀態/資料
**使用情境**: 僅在組件內部使用，無需與其他組件共享的狀態
**使用方式**:
- 需驗證的表單欄位狀態: VeeValidate(`useForm`、`useField`)
- 模板狀態: Vue 3(`ref`、`reactive`)
- 一般常數/變數: JS(`const`、`let`); **禁止**: `var`
**使用範例**:
```js
// 需驗證的表單欄位狀態
const { errors, validate, setValues } = useForm({
  validationSchema,
  initialValues: {
    fieldName: '',
  },
  validateOnMount: false,
})
const { value: fieldValue } = useField('fieldName');
<q-input v-model="fieldValue" dense outline />

// 模板狀態
const localState = ref('initialValue');
const localReactiveState = reactive({
  propertyName: 'initialValue',
});
<div>{{ localState }}</div>
<div>{{ localReactiveState.propertyName }}</div>

// 一般常數/變數
const CONST = 'constant';
let variableValue = 'variable';
```

---

## 組件狀態
**使用情境**: 需要在父子組件之間共享的狀態
**使用方式**:
- 父組件傳遞給子組件: Vue 3(`props`)
- 子組件傳遞給父組件: Vue 3(`emit`)
**使用範例**: 
```js
// 父組件傳遞給子組件
<ChildComponent :propName="propValue" />
// 子組件接收父組件傳遞的資料
const props = defineProps({
  propName: String
});

// 子組件傳遞給父組件
emit('eventName', eventValue);
// 父組件接收子組件傳遞的資料
<ChildComponent @eventName="handleEvent" />
```

---

## 路由狀態
**使用情境**: 需要在不同路由之間共享的狀態
**使用方式**:
- 路由參數: Vue Router(`state`)
**使用範例**:
```js
// 設定路由參數
router.push({ name: 'routeName', state: { stateName: 'stateValue' }});
// 取得路由參數
const stateValue = router.currentRoute.value.state.stateName;
```

## 全局狀態
**使用情境**: 需要在整個應用程式中共享的狀態
**使用方式**:
- 使用 Pinia 建立全局狀態管理
**可用全域狀態**:

| Store | Import 路徑 | 提供狀態 | 提供方法 | 適用情境 |
|---|---|---|---|---|


**使用範例**:
```js
// 建立 Pinia store
import { defineStore } from 'pinia';
export const useGlobalStore = defineStore('globalStore', {
  state: () => ({
    globalStateName: 'globalStateValue',
  }),
    actions: {
    setGlobalState(value) {
      this.globalStateName = value;
    },
  },
});
// 使用 Pinia store
import { useGlobalStore } from '@/stores/globalStore';
const globalStore = useGlobalStore();
globalStore.setGlobalState('newValue');
```
