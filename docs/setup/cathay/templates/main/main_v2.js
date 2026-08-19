import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import quasar from '@/assets/libs/QuasarPlugin.js'
import router from './router'
import '@/assets/libs/YupZhTw.js'
import '@/assets/libs/CathayValidateRules.js'

import notification from '@/assets/plugins/CathayNotification/index.js'
import loader from '@/assets/plugins/CathayLoader/index.js'
import cathayAxios from '@/assets/plugins/CathayAxios/index.js'
import cathayDialog from '@/assets/plugins/CathayDialog.js'

import 'vue-cathaylife-component/src/assets/scss/cathaylife-internal.scss'
import 'vue-cathaylife-component/src/assets/css/cub-lib-view-iconfont.min.css'
import 'vue-cathaylife-component/src/assets/css/cxl-lib-view-iconfont.css'
import 'vue-cathaylife-component/src/assets/css/cxl-ts-lib-view-iconfont.css'
import 'vue-cathaylife-component/dist/vue-cathaylife-component.css'

const app = createApp(App)
app.use(createPinia())
app.use(quasar)
app.use(notification)
app.use(loader)
app.use(cathayAxios, { showNotifyMsg: true })
app.use(cathayDialog, { quasar })
app.use(router)
app.mount('#app')
