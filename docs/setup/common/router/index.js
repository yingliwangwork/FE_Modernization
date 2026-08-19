import { createRouter, createWebHistory } from "vue-router";
import routerMap from "./router.js";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: routerMap.routes,
});

/**
 * 全域路由前置守衛
 * @param {import('vue-router').RouteLocationNormalized} to 目標路由
 * @param {import('vue-router').RouteLocationNormalized} from 來源路由
 * @returns {boolean} 是否允許進入目標路由
 */
router.beforeEach(async (to, from) => {
  return true;
});

export default router;