# 繁體中文輸入法調研（2026）

> 使用者情境：Windows 11、**打拼音**、想要**台灣標準字**輸出、重視
> **穩定 / 省資源 / 不崩潰**。曾用過 Rime（小狼毫 Weasel），體驗不錯。

---

## Current checkpoint（2026-06-27）

- 實機使用 **Weasel 0.17.4**。
- 預設方案固定為 `luna_pinyin_tw`，`schema_list` 不再列出
  `luna_pinyin_simp`，避免切回輸入法時恢復成簡體 schema。
- 預設輸出為臺灣正體；`Ctrl+Shift+4` 仍可切換繁簡，實作為同一 schema 內
  toggle `zh_simp`。
- 為兼容實際 key event，繁簡切換同時綁定 `Control+Shift+4` 與
  `Control+Shift+dollar`。
- 字形修正採雙保險：基礎詞庫正規化 + `simplifier@tw_fix`。
- 最新穩定紀錄見 [`docs/checkpoint-2026-06-27.md`](docs/checkpoint-2026-06-27.md)。
- **2026-06-28**：新增 [`website/`](website/) —— 商業級靜態比較網站（微軟 IME vs Rime）＋
  IconFlow 圖標，**已上線 Cloudflare Pages**：<https://zhengti-input-lab.pages.dev>。
  部署說明見 [`website/README.md`](website/README.md)；
  本次紀錄見 [`docs/checkpoint-2026-06-28.md`](docs/checkpoint-2026-06-28.md)。

---

## 0. 核心認知：「爲 vs 為」是字形標準問題，不是穩定性問題

- **為** = 台灣教育部標準字（國字標準字體）。
- **爲** = OpenCC 所謂「標準繁體 / 大陸繁體」常見字形。
- 同類差異還有：眾/衆、裡/裏、麼/麽、群/羣、線/綫……
- 根因：簡繁/異體轉換若走一般 `s2t`，會吐非台灣字形；走 **OpenCC 台灣正體
  （`t2tw` / `TWVariants`）** 可修正「眾、裡」等，**但 `t2tw` 收錄不全——
  「爲」就漏掉了**（2026-06 實測確認，原本「t2tw 就夠」的認知有誤）。
- 因此本專案採**雙保險**：直接修基礎詞庫 `luna_pinyin.dict.yaml`（跨 schema 生效）
  ＋ 在 `luna_pinyin_tw` 加一道 `tw_fix` OpenCC 補正。
- **重點：此問題在 Rime 內可宣告式修正，不必更換輸入法。**
- 📖 完整對照表與實作紀錄見 [`docs/字形對照表.md`](docs/字形對照表.md)、
  [`docs/字形正規化-實作紀錄.md`](docs/字形正規化-實作紀錄.md)。

---

## 1. 各輸入法優缺點整理（針對「拼音 + 繁體」情境）

### Rime / 小狼毫（Weasel）— ★ 拼音使用者的最佳解
**優點**
- 開源、免費、長期維護，**極穩定、資源占用低、幾乎不崩潰**。
- 拼音方案成熟：朙月拼音 `luna_pinyin`、地球拼音、霧凇拼音 `rime-ice`。
- **字形/詞庫完全可控**：每個轉換都是純文字字典，可精準新增/刪除/加權
  任一 case（這正是「修掉爛提示」需求的正解）。
- 設定可版本控制（git）、可在多機同步、重灌可還原。

**缺點**
- 設定門檻高，全靠 `*.custom.yaml` 自己調。
- 預設方案字形不一定是台灣標準，需自行掛 `t2tw`（見第 3 節）。

### 微軟拼音（微软拼音，Windows 內建）— 勉強堪用
**優點**：零安裝、零額外資源、相容性與穩定性最高。
**缺點**：**以簡體為核心**，繁體只是輸出轉換；**字形（爲/為）控制差**；
核心模型黑箱、夾帶雲端預測，**無法精準移除單一錯誤 case**；自學記錄會被
更新/雲端反覆洗回。→ 對「拼音 + 台灣字形 + 想精修」需求不理想。

### 微軟注音 / 新酷音 Chewing 26.x / 自然輸入法 — 對你不適用
- 皆為**注音**導向（新酷音 2026 已用 Rust 重寫、原生 TSF、很穩很省，但
  注音）。你打拼音 → **不適用**，僅列出供日後參考。
- 自然輸入法完整版**付費**；Lite 免費但功能受限、資源占用較高。

### 搜狗 / 百度拼音 — 不建議
簡體導向、隱私疑慮、廣告、資源占用大。

### 已淘汰
- Google 拼音 / Google 注音、Yahoo 奇摩輸入法：**已停止維護，勿用**。

---

## 2. 「直接改掉微軟 IME 的錯誤提示」可行嗎？

**想法對、載體錯。**
- 能改的只有表層：清自學字典、加「使用者自訂片語」抬高優先序。
- 改不到核心：黑箱模型 + 雲端預測，無法精準刪改單一 case；自學/雲端會
  反覆洗回；無可版本控制的設定檔，重灌歸零。
- **正解**：把這份「精準控制」的需求放到 **Rime**，用字典一勞永逸鎖死。

---

## 3. 已採用路線：留在 Rime，把字形修成台灣標準

目前方案固定為 `luna_pinyin_tw`：

- `zh_tw` 預設開啟，套用 `t2tw.json`。
- `tw_fix` 補上 `t2tw` 漏掉的臺灣字形。
- `zh_simp` 作為最後一層簡體輸出濾鏡，供 `Ctrl+Shift+4` 切換。
- 不再使用 `luna_pinyin_simp` 作為日常方案，避免 Rime 記住簡體 schema。

---

## 來源
- 新酷音 Chewing：https://chewing.im/download.html ・ https://github.com/chewing/windows-chewing-tsf/releases
- 2026 新酷音評測：https://pcrookie.com/chewing/
- Rime 小狼毫：https://rime.im/release/weasel/ ・ https://github.com/rime/weasel
- 修正 Rime 注音・臺灣正體異體字（爲/為）：http://blog.pulipuli.info/2022/04/fixing-the-problem-of-opencc-issues-when-typing-with-bopomofotw-of-fcitx-rime.html
- 微軟繁中輸入法：https://support.microsoft.com/en-us/windows/microsoft-traditional-chinese-ime-ef596ca5-aff7-4272-b34b-0ac7c2631a38
- 霧凇拼音 rime-ice：https://github.com/iDvel/rime-ice
