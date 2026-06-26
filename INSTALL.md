# Rime 小狼毫 — 實機現況與操作（Windows 11）

> 2026-06-27 checkpoint：**Rime 已設定妥當**，毋須重裝、毋須重啟。

## 實機現況
- 已安裝 **Weasel 0.17.4**（穩定的 0.17 線，非會崩的 0.16.x）。
- 方案清單：`luna_pinyin_tw`（臺灣正體，**唯一預設 schema**）。
  簡體輸出改由 `Ctrl+Shift+4` 在同一 schema 內切換，避免 Rime 記住
  `luna_pinyin_simp` 後切回來又變簡體。
- `Ctrl+Shift+4` 同時綁定 Rime 可能收到的兩種 key event：
  `Control+Shift+4`、`Control+Shift+dollar`。
- `luna_pinyin_tw` **內建 t2tw 字形轉換**（`option_name: zh_tw`，預設開）
  → 可得到「眾/裡/麼/群」等台灣字。
- ⚠️ **更正（2026-06-26）**：t2tw 收錄不全，**「爲」不會被轉成「為」**，
  Rime 的 luna_pinyin 詞庫本身仍會吐「爲」。已透過「直改基礎詞庫 + tw_fix 補正」
  解決，詳見 `docs/字形正規化-實作紀錄.md`。
- 自訂鍵位：emacs 編輯、逐詞移動、`- =` 與 `, .` 翻頁。
- 外觀：已套用 aqua 配色、橫排、微軟正黑體、內嵌拼音（本次變更）。

> 註：早先以為「爲」只來自微軟輸入法、Rime 不會出現——後經實測，Rime 的
> luna_pinyin 詞庫也會吐「爲」（t2tw 漏字）。兩邊都需處理；Rime 這邊已修。

## 立即操作（無需重啟）
1. `Win + 空白鍵` 切換到「小狼毫 / Weasel」。
2. 若候選出的是簡體（为），按 `Ctrl+Shift+4` 切回繁體。若曾被 Rime 記成
   簡體 schema，本次設定已移除 `luna_pinyin_simp` 方案入口並重設為
   **「朙月拼音·臺灣正體」**。
3. 測試：`wei`→為、`zhong`→眾、`li`→裡、`me`→麼、`qun`→群。
4. 外觀或設定若沒變，右鍵小狼毫圖示 →「重新部署」。

## 防止「爲」復發（建議）
- 設定 → 時間與語言 → 語言與地區 → 中文(繁體) → 語言選項 →
  **移除「微軟注音/微軟拼音」**，只留小狼毫，就不會誤切回去打出「爲」。

## 版本維護
- 目前已是 **Weasel 0.17.4**。未來小狼毫升級後，需確認安裝路徑與 registry
  `WeaselRoot`，再重新部署。
- 注意：升級會替換輸入服務 DLL，**建議升級後登出再登入一次**（非強制、
  不會關機重開）。

## 備份 / 還原
- 本資料夾已 `git init`，`rime-config/` 為設定還原點，`rime-sync/` 為自學詞庫備份。
- **同步設定**：`%APPDATA%\Rime\installation.yaml` 已加
  `sync_dir: "D:/AI_Projects/traditional-chinese-ime/rime-sync"`。
- **平時備份**：右鍵小狼毫圖示 →「同步」(或 `WeaselDeployer.exe /sync`)，
  詞庫快照會寫進 `rime-sync/<installation_id>/`，再 `git commit && git push` 即雲端備份。
- **換機/重灌還原**：
  1. 裝 Weasel 0.17.x → `WeaselSetup.exe /t`（繁體註冊）→ 登出再入。
  2. `git clone` 本 repo。
  3. 把 `rime-config/` 的 `*.custom.yaml` 複製到 `%APPDATA%\Rime\`。
  4. 在 `installation.yaml` 設 `sync_dir` 指向 clone 下來的 `rime-sync/`。
  5. 右鍵「同步」→ 詞庫自動合併回來 → 右鍵「重新部署」。

## 已知問題應急
- 候選窗重複顯示（少數，issue #1771）：regedit 刪重複的 weasel 註冊項、登出再入。
- 系統管理員視窗 / 部分全螢幕遊戲輸入異常：臨時切英文或系統內建。

## 踩坑紀錄：Win+Space 切不到小狼毫（2026-06-25 實際發生）
- 症狀：Rime 已裝、DLL/CLSID 都在，但 Win+Space 切不到，輸入法清單裡沒有它。
- 根因：TSF **語言 profile 註冊不完整**——
  `HKLM\SOFTWARE\Microsoft\CTF\TIP\{A3F4CDED-B1E9-41EE-9CA6-7B4D0DE6CB0A}\
  LanguageProfile\0x0404`（及 0x0804/0x0c04）存在但**內容全空**（無 profile 子鍵、
  無 Description/Enable）。即上次安裝沒跑完註冊/沒登出造成。
- 解法（已驗證）：以系統管理員執行官方工具補註冊（`/t` = 繁體）：
  `& 'D:\Software\System\Rime\weasel-0.17.4\WeaselSetup.exe' /t`
  → 會自動把「中文(繁體,台灣) + 小狼毫」加入語言清單，profile Enable=1。
- 之後若 Win+Space 仍沒出現，**登出再登入一次**（非關機重開）即生效。
- WeaselSetup.exe 其他參數：`/i` 安裝、`/u` 卸載、`/lt` 設繁體、`/ls` 設簡體、
  `/userdir:<dir>` 設使用者資料夾、`/eu /du` 開關自動更新。
