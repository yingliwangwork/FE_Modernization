import axios from 'axios'
import { Loading, Notify } from 'quasar'

const instance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

/**
 * 請求攔截器
 * 顯示 loading 遮罩，可於此加入共用 header（如 token）
 */
instance.interceptors.request.use(
  (config) => {
    Loading.show()
    return config
  },
  (error) => {
    Loading.hide()
    return Promise.reject(error)
  },
)

/**
 * 回應攔截器
 * 關閉 loading 遮罩，並用 notify 統一攔截訊息（不論成功失敗）
 */
instance.interceptors.response.use(
  (response) => {
    Loading.hide()
    Notify.create({ type: 'positive', message: '請求成功' }) // TODO: 依實際 API 回傳格式調整訊息內容
    return response.data
  },
  (error) => {
    Loading.hide()
    Notify.create({ type: 'negative', message: error.message || '請求失敗' })
    return Promise.reject(error)
  },
)

export default instance
