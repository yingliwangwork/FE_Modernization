# 路由註冊規範

**使用情境**: 註冊功能頁面路由
**使用方式**: 於 `@/router/router.js` 中註冊路由
**必須**: 根路由使用共用佈局(`BaseLayout`)
**使用範例**:
```js
// @/router/router.js
const BaseLayout = () => import('@/components/BaseLayout.vue');
const routes = [
    {
        path: '/',
        component: BaseLayout,
        children: [],
    },
    {
        path: '/<ModuleCode>',
        name: '<ModuleCode>',
        component: BaseLayout,
        children: [
            {
                path: '<FeatureCode>',
                name: '<FeatureCode>',
                component: () => import('@/views/<ModuleCode>/<FeatureCode>.vue'),
                children: [
                    {
                        path: '<SubPageName>',
                        name: '<FeatureCode><SubPageName>',
                        component: () => import('@/views/<ModuleCode>/<FeatureCode>/<FeatureCode><SubPageName>.vue')
                    }
                ],
            }
        ],
    },
];
```