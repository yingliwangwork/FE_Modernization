---
version: alpha
name: "CMP-SEARCH-ACTION — 查閱動作列"
spacing:
  margin-top: "8px"
omitted:
  - rounded
---

# CMP-SEARCH-ACTION 樣式規格

## Overview

查閱動作列，fixture-case v1，SCR-01 全部已知狀態。E-05：inputs/frontend/styles/base.css 的匹配規則；SHA-256 見 [inventory](../../../../renovation/fixture-case/source-inventory.json)。僅此 stylesheet，無其他來源 cascade；沒有批准新視覺設計。基礎字型／文字色作用於本頁繼承內容，原生控制依瀏覽器預設。

[實際 CSS](../../styles/CMP-SEARCH-ACTION.css) · [prototype](../../prototypes/SCR-01.html) · [tokens](../../styles/tokens.json) · [tracking](../../../../renovation/fixture-case/tracking.md)。DESIGN.md 使用 skill 指定 alpha profile；DTCG 2025.10 JSON 是獨立交換產物，沒有使用官方 validator。

## Colors

CMP-PAGE 來源文字 #222；CMP-TABLE 的表頭與格子边框 #555；CMP-SEARCH-ACTION 無獨立色彩，只沿用頁面及原生控制呈現。各適用宣告見本元件表。（E-05）

## Typography

全頁來源 font-family 為 sans-serif；沒有額外字級／行高／字重宣告。按鈕及輸入的原生繼承由瀏覽器決定，不新增 CSS。（E-05）

## Layout

精確宣告及條件見逐項映射；只保留來源四行規則。table 100% 寬度保留相對關係，沒有轉成固定 px；複合 margin 不拆錯值。（E-05）

## Elevation & Depth

CMP-TABLE 格線為 1px solid #555，border-collapse 為 collapse；其他元件沒有來源 elevation 宣告，不新增陰影或層級。（E-05）

## Shapes

未有來源圓角宣告，rounded 群組省略；不創造圓角或 breakpoint。

## Components

### CMP-SEARCH-ACTION／來源唯一樣式

| STYLE | 適用條件 | token 或正文規則 | 規範值 | CSS selector/property/value | 證據 | 瀏覽器步驟／預期 computed style |
|---|---|---|---|---|---|---|
| STYLE-11 | CMP-SEARCH-ACTION/SCR-01 全狀態 | action.marginTop | 8px | [CMP-SEARCH-ACTION.css](../../styles/CMP-SEARCH-ACTION.css)：`.action-bar` / `margin-top: 8px` | E-05 | 開 SCR-01 初始及成功兩列后 inspect 匹配元素；8px |

本元件表的 px dimension 與 sRGB color 可映射 DTCG；sans-serif 關鍵字、collapse、百分比 100%、複合 margin、solid 及 left 保留於正文/CSS，不宣稱全部樣式都已有 token。table.marginBlock 只表示上下 16px，左右零留 CSS。tokens 未由 CSS custom property 引用，文件和檢查逐項比對值。

## Do's and Don'ts

只使用提供來源樣式，不新增 hover、focus、禁用、色票、字型階級或 spacing 尺度；此為 task.txt 的來源限制。交付元件樣式不表示原生控制所有 computed 值均已取得。

## Adoption Scope

本頁呈現限定 fixture-case，來源 E-05 及內容雜湊固定；不推廣成全系統標準。CMP-SEARCH-ACTION 行為引用既有共用契約 fixture-component-v1，樣式只記本頁作用。審閱工具沒有產品 CMP/UI ID，沒有額外產品 CSS。實際 browser computed style 尚未測，由 parent 另行驗證；來源執行畫面缺失，不能宣稱像素等價（tracking V-04）。
