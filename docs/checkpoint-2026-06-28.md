# Checkpoint 2026-06-28 — 比較網站 + 圖標 + 桌面捷徑

## 本次完成

### 1. 靜態比較網站 `website/`
高質量、商業級佈局的單頁靜態網站，主題：**微軟 IME vs Rime 小狼毫** 在
「Windows 11 · 拼音 · 台灣正體」情境下的優缺點對比。

- **內容來源**：`COMPARISON.md`、`README.md`、`TODO.md`、`docs/字形對照表.md`
  —— 網站只是視覺化，無新增私人資料。
- **章節**：Hero ＋ 數字滾動指標／六維總評勝負卡／六大維度可切換對比表／
  繁體字形改進（爲→為 三層防護 ＋ 15 組字形 chip 牆）／提升路線圖 Kanban
  （已落實 7・規劃中 3・探索中 3，對應 `TODO.md`）／三步驟上手／來源。
- **技術**：語意化 HTML、CSS 變數＋RWD＋玻璃擬態、原生 JS（標籤切換／
  IntersectionObserver 捲動淡入／數字 count-up／行動選單／章節高亮）。
  **零外部相依**，可離線開啟、可任意靜態託管。
- **部署**：見 [`website/README.md`](../website/README.md)
  （GitHub Pages / Cloudflare Pages / Netlify 等）。

### 2. 圖標（IconFlow）
- 工具：`D:\AI_Projects\ai-iconflow`，依 DESIGN_PLAYBOOK 流程：
  diverge → bake-off → review → build。
- 三個 finalist 比稿：`繁`（17 畫，16px 糊成一團）、`為+caret`（小尺寸雜訊）、
  **`正`（勝出）** —— 最簡潔輪廓、16px 仍清晰、意即「正體」、雙色背景皆可讀。
- 母檔：[`website/icon-master.svg`](../website/icon-master.svg)
  （teal→cyan→blue 漸層方角＋白色「正」）。
- 產物：`website/icons/` 全套 favicon／PWA／`icons/icon.ico`（16–256 多尺寸）。
- 評分（6 軸）：legibility 5・silhouette 5・distinctiveness 4・contrast 5・
  maskable 5・craft 5；`check` 無警告。
- 站內品牌字（nav/footer）由 `繁` 改為 `正`，與圖標統一識別。

### 3. 桌面捷徑
- 在 `C:\Users\snowy\Desktop` 與 OneDrive Desktop 各建一個
  **「正體輸入 Lab.lnk」**，target = `website/index.html`，
  icon = `website/icons/icons/icon.ico`。
- ⚠️ **踩坑**：`WScript.Shell` 以系統 ANSI code page 編 `.lnk` 檔名，CJK 檔名
  直接 `.Save()` 會失敗（檔名被轉成 `????`）。
  解法：先存 ASCII 暫名 → COM 讀回確認 target/icon → 用
  `[System.IO.File]::Move` 改成 CJK 名（.NET 為 Unicode-safe）。

## Repo 同步
- `website/` 已鏡像進公開子 repo `rime-tw-config/website/`（站台無 userdb，可公開）。
- 私有外層 repo：本檔 ＋ README/TODO ＋ `website/` 一併提交並 push。

## 後續（沿用 `TODO.md`）
- 修 `backup.ps1` 的 LevelDB 鎖；個人詞庫 `custom_phrase`；每日自動備份。
- 上游 PR 15 組字形修正；評估 rime-ice；精簡 IME 清單（移除 ja）。
