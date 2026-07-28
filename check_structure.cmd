@echo off
chcp 65001 >nul
title فهمني القرآن - فحص هيكل المشروع

echo ==============================================
echo   📋 فحص هيكل مشروع فهمني القرآن
echo ==============================================
echo.

:: التحقق من مجلد السور
if exist "السور\" (
    echo ✅ مجلد السور موجود
    set /a total=0
    for /d %%d in ("السور\*") do set /a total+=1
    echo    عدد المجلدات: %total%
) else (
    echo ❌ مجلد السور غير موجود
)

echo.
echo ===== الملفات الصوتية =====
echo.

for /d %%d in ("السور\*") do (
    set count=0
    for %%f in ("%%d\*.mp3" "%%d\*.aac" "%%d\*.wav" "%%d\*.ogg") do (
        set /a count+=1
    )
    if !count! gtr 0 (
        echo 📖 %%~nxd: !count! ملف
    )
)

echo.
echo ===== مشروع Flutter =====
echo.

if exist "fahemni_alquran\pubspec.yaml" (
    echo ✅ ملف pubspec.yaml موجود
) else ( echo ❌ pubspec.yaml غير موجود )

if exist "fahemni_alquran\lib\main.dart" (
    echo ✅ ملف main.dart موجود
) else ( echo ❌ main.dart غير موجود )

if exist "fahemni_alquran\lib\config" (
    echo ✅ مجلد config موجود
) else ( echo ❌ config غير موجود )

if exist "fahemni_alquran\lib\models" (
    echo ✅ مجلد models موجود
) else ( echo ❌ models غير موجود )

if exist "fahemni_alquran\lib\services" (
    echo ✅ مجلد services موجود
) else ( echo ❌ services غير موجود )

if exist "fahemni_alquran\lib\screens" (
    echo ✅ مجلد screens موجود
) else ( echo ❌ screens غير موجود )

if exist "fahemni_alquran\lib\widgets" (
    echo ✅ مجلد widgets موجود
) else ( echo ❌ widgets غير موجود )

echo.
echo ===== HTML Test App =====
echo.

if exist "test_app.html" (
    echo ✅ test_app.html موجود
) else ( echo ❌ test_app.html غير موجود )

echo.
echo ===== R2 Upload Script =====
echo.

if exist "upload_r2.py" (
    echo ✅ upload_r2.py موجود
) else ( echo ❌ upload_r2.py غير موجود )

if exist ".env.example" (
    echo ✅ .env.example موجود
) else ( echo ❌ .env.example غير موجود )

echo.
echo ==============================================
echo   ✅ الفحص اكتمل
echo ==============================================
pause
