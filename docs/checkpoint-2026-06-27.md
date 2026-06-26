# Checkpoint 2026-06-27

本 checkpoint 記錄目前 Rime / 小狼毫設定的穩定狀態，作為後續維護與 GitHub
同步的基準。

## 目前狀態
- 實機使用 **Weasel 0.17.4**，安裝路徑為
  `D:\Software\System\Rime\weasel-0.17.4`。
- 預設輸入方案固定為 `luna_pinyin_tw`，`schema_list` 不再列出
  `luna_pinyin_simp`，避免 Rime 把上次使用的簡體 schema 記成預設。
- `user.yaml` 已重設為 `previously_selected_schema: luna_pinyin_tw`。
- 預設輸出為臺灣正體；`zh_tw` 固定 `reset: 1`，負責 `t2tw` 與 `tw_fix`
  字形補正。
- `Ctrl+Shift+4` 仍可切換繁簡，但改為在同一個 `luna_pinyin_tw` schema 內
  toggle `zh_simp`，而不是切到另一個 schema。
- 為兼容 Windows / Rime 實際 key event，繁簡切換同時綁定：
  - `Control+Shift+4`
  - `Control+Shift+dollar`

## 字形修正
- 基礎詞庫層：`rime-config/patch-luna-dict.ps1` 將 `luna_pinyin.dict.yaml`
  中 15 組舊字形正規化為臺灣正字。
- 輸出層防護：`luna_pinyin_tw.custom.yaml` 掛上 `simplifier@tw_fix`，
  使用 `opencc/tw_fix.json` 與 `tw_fix.txt`。
- 目前測試重點：`wei`→為、`zhong`→眾、`li`→裡、`me`→麼、`qun`→群。

## 驗證紀錄
- 已執行 `WeaselDeployer.exe /deploy`。
- deploy log 顯示：`2 success, 0 failure`。
- build 結果確認：
  - `build/default.yaml` 的 `schema_list` 只剩 `luna_pinyin_tw`。
  - `build/default.yaml` 與 `build/luna_pinyin_tw.schema.yaml` 同時含
    `Control+Shift+4` 與 `Control+Shift+dollar`。
  - `build/luna_pinyin_tw.schema.yaml` 含 `simplifier@tw_fix` 與
    `simplifier@zh_simp`。
- `git diff --check` 已通過。

## Repo 分工
- `traditional-chinese-ime`：個人完整工作 repo，含 `rime-sync/` 個人輸入歷史。
- `rime-tw-config/`：公開分享版 repo，不包含個人 `rime-sync/`。

## 後續注意
- 小狼毫升級或重裝可能覆蓋共享詞庫，需重跑
  `rime-config/patch-luna-dict.ps1` 後重新部署。
- `backup.ps1` 仍需修正：目前 `/sync` 可能因 LevelDB lock 靜默失敗，且需使用
  實機 deployer 路徑。
