# patch-luna-dict.ps1
# 將小狼毫共享資料夾中的 luna_pinyin.dict.yaml 內舊字形/異體就地正規化為臺灣正字。
# luna_pinyin 上游沿用舊字形（最明顯是「爲」），t2tw 不會處理；直接修詞庫可在
# 所有 schema（luna_pinyin / luna_pinyin_tw / luna_pinyin_simp 漢字模式）一致生效。
#
# 用法：小狼毫升級覆蓋詞庫後重跑本腳本，然後重新部署：
#   powershell -ExecutionPolicy Bypass -File patch-luna-dict.ps1
#   & "<WeaselRoot>\WeaselDeployer.exe" /deploy
#
# 注意：此處替換的字皆為「純字形、無語義分裂、臺灣正體單一標準字」。
# 與 opencc/tw_fix.txt 對照表一致（見 opencc/tw_fix.notes.md）。

$ErrorActionPreference = 'Stop'

# 1) 定位 WeaselRoot（共享資料夾）
$root = (Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Rime\Weasel' -ErrorAction SilentlyContinue).WeaselRoot
if (-not $root) { $root = (Get-ItemProperty 'HKLM:\SOFTWARE\Rime\Weasel' -ErrorAction SilentlyContinue).WeaselRoot }
if (-not $root) { throw 'WeaselRoot 找不到，請手動指定 $dict 路徑' }
$dict = Join-Path $root 'data\luna_pinyin.dict.yaml'
if (-not (Test-Path $dict)) { throw "找不到詞庫：$dict" }

# 2) 字形對照（原字 -> 臺灣正字）
$map = [ordered]@{
  '着'='著'; '爲'='為'; '裏'='裡'; '麪'='麵'; '羣'='群'; '衆'='眾'; '牀'='床';
  '啓'='啟'; '麽'='麼'; '綫'='線'; '峯'='峰'; '鷄'='雞'; '鬬'='鬥'; '鬭'='鬥'; '飈'='飆'
}

# 3) 備份 + 套用（字元級、保留 CRLF、UTF-8 無 BOM）
Copy-Item $dict "$dict.bak" -Force
$text = [System.IO.File]::ReadAllText($dict, [System.Text.Encoding]::UTF8)
$before = ($map.Keys | ForEach-Object { ([regex]::Matches($text,[regex]::Escape($_))).Count } | Measure-Object -Sum).Sum
foreach ($k in $map.Keys) { $text = $text.Replace([string]$k, [string]$map[$k]) }
[System.IO.File]::WriteAllText($dict, $text, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "[OK] 已正規化 $before 處舊字形 -> $dict" -ForegroundColor Green
Write-Host "請接著執行： & `"$root\WeaselDeployer.exe`" /deploy" -ForegroundColor Cyan
