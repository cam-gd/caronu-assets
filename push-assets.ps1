param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Urls)

# push-assets.ps1
# Telecharge les fichiers generes et les pousse sur GitHub
# pour que Claude puisse les regarder.
#
# UTILISATION :
#   .\push-assets.ps1 "url1" "url2" "url3"
#
# Gere les images (.png, .jpg, .webp) ET les videos (.mp4).

$GitHubUser = "cam-gd"
$repoPath   = "C:\Users\cagal\caronu-assets"

# ---------------------------------------------------------------
# Ne rien modifier en dessous
# ---------------------------------------------------------------

if (-not $Urls -or $Urls.Count -eq 0) {
    Write-Host "Aucune URL fournie." -ForegroundColor Red
    Write-Host 'Usage : .\push-assets.ps1 "https://..." "https://..."'
    exit 1
}

if (-not (Test-Path $repoPath)) {
    Write-Host "Dossier $repoPath introuvable." -ForegroundColor Red
    exit 1
}

Set-Location $repoPath

$lot = "lot-" + (Get-Date -Format "yyyyMMdd-HHmmss")
New-Item -ItemType Directory -Path $lot -Force | Out-Null

$i = 1
$rawUrls = @()

foreach ($url in $Urls) {

    # Recupere l'extension reelle du fichier (.png, .mp4, ...)
    $sansParams = ($url -split '\?')[0]
    $ext = [System.IO.Path]::GetExtension($sansParams)
    if ([string]::IsNullOrWhiteSpace($ext)) { $ext = ".png" }

    $nom  = "{0:d2}{1}" -f $i, $ext
    $dest = Join-Path $lot $nom

    Write-Host "Telechargement $i / $($Urls.Count) ($ext) ..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -ErrorAction Stop
        $rawUrls += "https://raw.githubusercontent.com/$GitHubUser/caronu-assets/main/$lot/$nom"
    }
    catch {
        Write-Host "  Echec sur cette URL : $url" -ForegroundColor Yellow
    }
    $i++
}

if ($rawUrls.Count -eq 0) {
    Write-Host "Aucun fichier telecharge." -ForegroundColor Red
    exit 1
}

git add $lot
git commit -m "Assets $lot"
git push

Write-Host ""
Write-Host "=== COLLE CECI DANS LE CHAT CLAUDE ===" -ForegroundColor Green
Write-Host ""
foreach ($r in $rawUrls) { Write-Host $r }
Write-Host ""
