param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Urls)
if (-not $Urls) { Write-Host "Aucune URL fournie." -ForegroundColor Red; exit }
$lot = "lot-" + (Get-Date -Format "yyyyMMdd-HHmmss")
New-Item -ItemType Directory -Force -Path $lot | Out-Null
$i = 1
foreach ($u in $Urls) {
  $ext = [System.IO.Path]::GetExtension(($u -split '\?')[0])
  if (-not $ext) { $ext = ".png" }
  $nom = "{0}\{1:D2}{2}" -f $lot, $i, $ext
  Write-Host "Telechargement $i / $($Urls.Count) ($ext) ..."
  try { Invoke-WebRequest -Uri $u -OutFile $nom -ErrorAction Stop; $i++ }
  catch { Write-Host "  Echec sur cette URL : $u" -ForegroundColor Red }
}
git add $lot
git commit -m "Assets $lot"
git push
Write-Host ""
Write-Host "=== COLLE CECI DANS LE CHAT CLAUDE ===" -ForegroundColor Green
Get-ChildItem $lot | ForEach-Object {
  Write-Host "https://raw.githubusercontent.com/cam-gd/caronu-assets/main/$lot/$($_.Name)"
}
