import { defineConfig, loadEnv } from "vite";
import vue from "@vitejs/plugin-vue";
import path from "path";

export default ({ mode }) => {
  const _env = loadEnv(mode, process.cwd());
  const basePath = _env.VITE_NODE_ENV === "development" ? "/" : "/__PROJECT_NAME__/";
  const customTagsList = { a: ["href"] };
  return defineConfig({
    plugins: [
      vue(),
    ],
    base: basePath,
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
  });
};
