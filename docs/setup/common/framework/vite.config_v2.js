import { defineConfig, loadEnv } from "vite";
import { quasar, transformAssetUrls } from "@quasar/vite-plugin";
import vue from "@vitejs/plugin-vue";
import path from "path";

export default ({ mode }) => {
  const _env = loadEnv(mode, process.cwd());
  const basePath = _env.VITE_NODE_ENV === "development" ? "/" : "/__PROJECT_NAME__/";
  const customTagsList = { a: ["href"] };
  return defineConfig({
    plugins: [
      vue({
        template: {
          transformAssetUrls: {
            base: basePath,
            includeAbsolute: !transformAssetUrls.includeAbsolute,
            tags: { ...transformAssetUrls.tags, ...customTagsList },
          },
        },
      }),
      quasar({
        // 有自訂 quasar-variables.sass 樣式才需要設定 sassVariables
        sassVariables: "@/assets/sass/quasar-variables.sass",
      }),
    ],
    base: basePath,
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
  });
};
