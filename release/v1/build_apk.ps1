# ==============================================================================
# SCRIPT BUILD APK RELEASE CHO SHOPPEFAKE MOBILE (PowerShell)
# ==============================================================================
# Duong dan: e:\GitHub\ShoppeFake\release\v1\build_apk.ps1
# ==============================================================================

$ErrorActionPreference = "Stop"

# Xac dinh duong dan goc
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$MobileDir = Join-Path $ProjectRoot "mobile"
$OutputDir = $ScriptDir

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "       SHOPPEFAKE MOBILE - BUILD APK RELEASE AUTOMATION" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "[-] Thu muc goc du an : $ProjectRoot" -ForegroundColor Gray
Write-Host "[-] Thu muc mobile    : $MobileDir" -ForegroundColor Gray
Write-Host "[-] Thu muc xuat APK  : $OutputDir" -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Kiem tra Flutter SDK
Write-Host "`n[1/5] Kiem tra Flutter SDK trong moi truong PATH..." -ForegroundColor Yellow
$FlutterCmd = Get-Command "flutter" -ErrorAction SilentlyContinue
if (-not $FlutterCmd) {
    Write-Host "[X] LOI: Khong tim thay lenh 'flutter' trong PATH!" -ForegroundColor Red
    Write-Host "    Vui long kiem tra lai cai dat Flutter SDK va them vao PATH." -ForegroundColor Red
    exit 1
}
$FlutterVersion = flutter --version | Select-Object -First 1
Write-Host "[OK] Da tim thay: $FlutterVersion" -ForegroundColor Green

# 2. Di chuyen vao thu muc mobile
if (-not (Test-Path $MobileDir)) {
    Write-Host "[X] LOI: Khong tim thay thu muc mobile tai: $MobileDir" -ForegroundColor Red
    exit 1
}
Set-Location $MobileDir

# 3. Don dep cache cu & Tai goi dependency
Write-Host "`n[2/5] Don dep cache cu (flutter clean)..." -ForegroundColor Yellow
flutter clean

Write-Host "`n[3/5] Cap nhat thu vien dependencies (flutter pub get)..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] LOI: Lenh 'flutter pub get' that bai!" -ForegroundColor Red
    exit 1
}

# 4. Tien hanh build APK Release
Write-Host "`n[4/5] Dang bien dich APK Release (flutter build apk --release)..." -ForegroundColor Yellow
Write-Host "    Qua trinh nay co the mat vai phut tuy thuoc vao cau hinh may..." -ForegroundColor Gray
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] LOI: Bien dich APK that bai! Vui long kiem tra loi ben tren." -ForegroundColor Red
    exit 1
}

# 5. Kiem tra va sao chep APK sang thu muc release\v1
Write-Host "`n[5/5] Sao chep tep APK ra thu muc release/v1..." -ForegroundColor Yellow
$BuiltApkPath = Join-Path $MobileDir "build\app\outputs\flutter-apk\app-release.apk"

if (-not (Test-Path $BuiltApkPath)) {
    Write-Host "[X] LOI: Khong tim thay file APK sau khi build tai: $BuiltApkPath" -ForegroundColor Red
    exit 1
}

$TargetApkName = "ShoppeFake-v1-release.apk"
$DestinationApk = Join-Path $OutputDir $TargetApkName
$BackupApk = Join-Path $OutputDir "app-release.apk"

Copy-Item -Path $BuiltApkPath -Destination $DestinationApk -Force
Copy-Item -Path $BuiltApkPath -Destination $BackupApk -Force

$FileInfo = Get-Item $DestinationApk
$SizeInMB = [Math]::Round($FileInfo.Length / 1MB, 2)
$TimeStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "======================================================================" -ForegroundColor Green
Write-Host "                        BUILD APK THANH CONG!                         " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "[+] Tep APK chinh    : $DestinationApk ($SizeInMB MB)" -ForegroundColor White
Write-Host "[+] Ban sao phu      : $BackupApk" -ForegroundColor Gray
Write-Host "[+] Thoi gian        : $TimeStr" -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Green
