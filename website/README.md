# 正體輸入 Lab — 比較網站

一個高質量、商業級佈局的**靜態網站**，比較 **微軟 IME** 與 **Rime 小狼毫（Weasel）**
在「Windows 11 · 打拼音 · 要台灣正體」情境下的優缺點，並彙整繁體中文字形改進與我們對
Rime 的更新／提升路線圖。

> 🌐 **已上線**：<https://zhengti-input-lab.pages.dev>（Cloudflare Pages）

> 內容取自本 repo 的 `COMPARISON.md`、`README.md`、`TODO.md`、`docs/` —— 網站只是把它們
> 視覺化，無額外私人資料。

## 檔案結構

```
website/
├── index.html          單頁主體（繁體、語意化、無框架）
├── css/style.css       暗色商業級樣式，CSS 變數、RWD、玻璃擬態
├── js/main.js          原生 JS：標籤切換、捲動淡入、數字滾動、行動選單
├── icons/              IconFlow 產生的 favicon / app icon 全套
│   ├── favicon.svg / favicon.ico / apple-touch-icon.png
│   ├── icon-192.png / icon-512.png / icon-512-maskable.png
│   ├── site.webmanifest
│   └── icons/icon.ico  桌面捷徑用的多尺寸 .ico（16–256）
└── icon-master.svg     圖標母檔（「正」＝正體，teal→cyan→blue 漸層方角）
```

**零外部相依**：不載入任何 CDN、字型或追蹤腳本，可離線開啟、可直接靜態託管。

## 本機預覽

直接雙擊 `index.html`，或開啟一個本機伺服器以讓 `manifest`／相對路徑完全正確：

```bash
# 任一即可
python -m http.server 8080        # 然後開 http://localhost:8080
npx serve .
```

桌面已建立捷徑「正體輸入 Lab」，雙擊即用預設瀏覽器開啟本頁。

## 部署

此為純靜態站，任何靜態主機都能直接託管 `website/` 目錄。

### GitHub Pages
1. 將本 repo 推上 GitHub。
2. **Settings → Pages → Build and deployment → Source: Deploy from a branch**。
3. 選 `main`（或 `master`）分支、資料夾選 `/website`（若 Pages 不支援子目錄，
   見下方「子目錄注意」）。
4. 數十秒後即可在 `https://<user>.github.io/<repo>/` 取得。

> **子目錄注意**：GitHub Pages 的「branch 來源」只能選 `/` 或 `/docs`。若要直接發佈
> `website/`，最簡單是把內容放到 `docs/`，或改用 GitHub Actions（`actions/deploy-pages`）
> 指定 `path: website`。本 repo 採前者時，將 `website/*` 複製到 `docs/` 即可。

### Cloudflare Pages（本站採用，已上線）
本站以 **wrangler 直接上傳**部署（無需接 Git）。專案名 `zhengti-input-lab`，
production 分支 `main`：

```bash
# 一次性建立專案
npx wrangler pages project create zhengti-input-lab --production-branch main
# 每次發佈（從 repo 根目錄執行，上傳 website/）
npx wrangler pages deploy website --project-name zhengti-input-lab --branch main --commit-dirty=true
```

- `_headers` 提供安全標頭（CSP/nosniff/Referrer-Policy…）與分層快取；`404.html`
  為自訂錯誤頁，皆隨 `website/` 一併上傳。
- 附 `*.pages.dev` 網址與免費 HTTPS。

或改用 **Connect to Git**（每次 push 自動部署）：Dashboard → Workers & Pages →
Create → Pages → Connect to Git → 選 repo → Build command 留空、Build output
directory 填 `website`。

### Netlify / Vercel / 任意 S3、Nginx
把 `website/` 當作站台根目錄上傳即可，無建置步驟。

## 重新產生圖標

圖標由 `D:\AI_Projects\ai-iconflow`（IconFlow）產生。母檔為 `icon-master.svg`：

```bash
cd D:/AI_Projects/ai-iconflow
.venv/Scripts/python.exe -m iconflow build \
  "D:/AI_Projects/traditional-chinese-ime/website/icon-master.svg" \
  --out "D:/AI_Projects/traditional-chinese-ime/website/icons" \
  --targets web,tauri --name "正體輸入 Lab" \
  --theme "#2dd4bf" --bg "#070a14" --relative-paths
```

## 維護

- 對比內容若有變動，請同步更新 `../COMPARISON.md` 與本頁的對應表格。
- 路線圖（Kanban）對應 `../TODO.md`；完成項目時兩邊一起更新。
