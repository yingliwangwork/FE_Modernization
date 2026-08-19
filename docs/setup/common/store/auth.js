import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const token = ref('')
  const user = ref(null)

  /**
   * 使用者登入，成功後寫入 token 與使用者資訊
   * TODO: 串接登入 API
   */
  function login() {
    // TODO: 實作登入邏輯
  }

  /** 使用者登出，清除 token 與使用者資訊 */
  function logout() {
    token.value = ''
    user.value = null
  }

  return { token, user, login, logout }
})
