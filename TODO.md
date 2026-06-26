# 之後再做（TODO）

> 目前狀態：小狼毫可用、台灣字形正確、豎排+aqua+正黑體、自學詞庫已同步備份到
> 私有 GitHub、微軟拼音/簡體已移除。預設 schema 固定為 `luna_pinyin_tw`，
> `Ctrl+Shift+4` 可在同一 schema 內切換繁簡。
>
> **2026-06-26 更新**：完成字形正規化（爲→為 等 15 組，含基礎詞庫直改 + tw_fix
> 補正 + 自學詞庫就地替換）。
>
> **2026-06-27 checkpoint**：移除 `luna_pinyin_simp` 方案入口，避免 Rime 記住
> 簡體 schema；`Ctrl+Shift+4` 改切 `zh_simp`，並補上
> `Control+Shift+dollar` 相容鍵。詳見 `docs/checkpoint-2026-06-27.md`。
> 詳見 `docs/字形正規化-實作紀錄.md`、`docs/字形對照表.md`。

## 0. 待批准 / 待處理（新）
- [ ] **修 `backup.ps1`**：伺服器執行中 `/sync` 會因 LevelDB 鎖靜默失敗；
      deployer 路徑也對不上實機（`D:\Software\System\Rime\weasel-0.17.4`）。
- [ ] **上游 PR**（待你批准）：15 組字形修正提交 rime/rime-pinyin。
- [ ] **外層 repo 公開前隱私**：`rime-sync/` 含個人輸入歷史。公開分享請使用
      `rime-tw-config/`。

## 1. Rime 版本維護
- 目前實機已是 **Weasel 0.17.4**。
- ⚠️ 升級會重跑安裝程式、替換輸入服務 DLL，**有可能再次打亂 TSF profile 註冊**
  （就是這次 Win+Space 切不到的那個坑）。
- 升級後標準復原步驟：
  1. 系統管理員執行 `WeaselSetup.exe /t`（繁體重新註冊）。
  2. **登出再登入一次**。
  3. 右鍵小狼毫 →「重新部署」。
  4. 跑 `backup.cmd` 確認一切正常。
- 詳見 INSTALL.md 的「踩坑紀錄」。

## 2. 建個人詞庫（鎖定/排除特定詞）
- 目標：把常用詞固定、或把不想要的爛候選排掉（最初的需求）。
- 作法：建 `custom_phrase.txt`（簡單高頻詞）或 `personal.dict.yaml`（完整詞庫），
  掛到 luna_pinyin 的 translator。可版控、可同步。

## 3. 其他可選
- 若覺得整句預測不夠聰明 → 試 **雾凇拼音 rime-ice**（架構已預留）。
- 不用日語的話可一併移除 `ja`，Win+Space 只剩 英 / 繁中。
- 想自動備份 → 用「工作排程器」每日呼叫 `backup.cmd`（目前為手動一鍵）。
