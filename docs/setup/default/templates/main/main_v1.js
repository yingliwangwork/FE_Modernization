import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import quasar from '@/assets/libs/QuasarPlugin.js'
import router from './router'
import http from '@/assets/plugins/axios/index.js'
import '@/assets/libs/YupZhTw.js'
import '@/assets/libs/ValidateRules.js'

const app = createApp(App)
app.use(createPinia())
app.use(quasar)
app.use(router)
app.use(http)
app.mount('#app')
