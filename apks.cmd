@echo off
setlocal EnableDelayedExpansion

REM ========== CONFIG ==========
set "TOOLSDIR=SET Your Tool Path"
set "APKEDITOR_JAR="
set "APKEDITOR_VERSION="
set "APKEDITOR_LATEST="

set "SIGNER_JAR="
set "SIGNER_VERSION="
set "SIGNER_LATEST="

REM ========== CHECK APKEDITOR ==========
echo ==================  Checking for APKEditor update... ==================
echo.
for %%f in ("%TOOLSDIR%\apkeditor-*.jar") do (
    set "APKEDITOR_JAR=%%~nxf"
    set "APKEDITOR_VERSION=%%~nxf"
    goto :CHECK_SIGNER
)
goto :APKEDITOR_DOWNLOAD

:CHECK_SIGNER
set "APKEDITOR_VERSION=!APKEDITOR_VERSION:apkeditor-=!"
set "APKEDITOR_VERSION=!APKEDITOR_VERSION:.jar=!"

for /f %%v in ('powershell -Command "(Invoke-RestMethod 'https://api.github.com/repos/REAndroid/APKEditor/releases/latest').tag_name.TrimStart('v','V')"') do set "APKEDITOR_LATEST=%%v"

echo Installed: !APKEDITOR_VERSION!
echo Latest:    !APKEDITOR_LATEST!

if /I "!APKEDITOR_VERSION!" == "!APKEDITOR_LATEST!" (
    echo.
    echo APKEditor is up to date.
    goto :APKEDITOR_READY
)

set /p CHOICE=New APKEditor version available. Update? (Y/N): 
if /I "!CHOICE!"=="Y" (
    del "%TOOLSDIR%\apkeditor-*.jar"
    goto :APKEDITOR_DOWNLOAD
)
goto :APKEDITOR_READY

:APKEDITOR_DOWNLOAD
echo Downloading APKEditor...
powershell -Command "$r=Invoke-RestMethod 'https://api.github.com/repos/REAndroid/APKEditor/releases/latest'; $a = $r.assets | Where-Object { $_.name -like '*.jar' }; Invoke-WebRequest -Uri $a.browser_download_url -OutFile ('%TOOLSDIR%\' + $a.name)"
for %%f in ("%TOOLSDIR%\apkeditor-*.jar") do (
    set "APKEDITOR_JAR=%%~nxf"
    set "APKEDITOR_VERSION=%%~nxf"
)
set "APKEDITOR_VERSION=!APKEDITOR_VERSION:apkeditor-=!"
set "APKEDITOR_VERSION=!APKEDITOR_VERSION:.jar=!"
set "APKEDITOR_LATEST=!APKEDITOR_VERSION!"
goto :APKEDITOR_READY

:APKEDITOR_READY
if not defined APKEDITOR_LATEST set "APKEDITOR_LATEST=!APKEDITOR_VERSION!"

REM ========== CHECK UBER SIGNER ==========
echo.
echo ================ Checking for uber-apk-signer update... ================
echo.
for %%f in ("%TOOLSDIR%\uber-apk-signer-*.jar") do (
    set "SIGNER_JAR=%%~nxf"
    set "SIGNER_VERSION=%%~nxf"
    goto :SIGNER_COMPARE
)
goto :SIGNER_DOWNLOAD

:SIGNER_COMPARE
set "SIGNER_VERSION=!SIGNER_VERSION:uber-apk-signer-=!"
set "SIGNER_VERSION=!SIGNER_VERSION:.jar=!"

for /f %%v in ('powershell -Command "(Invoke-RestMethod 'https://api.github.com/repos/patrickfav/uber-apk-signer/releases/latest').tag_name.TrimStart('v','V')"') do set "SIGNER_LATEST=%%v"

echo Installed: !SIGNER_VERSION!
echo Latest:    !SIGNER_LATEST!

if /I "!SIGNER_VERSION!" == "!SIGNER_LATEST!" (
    echo.
    echo Signer is up to date.
    goto :SIGNER_READY
)

set /p CHOICE=New signer version available. Update? (Y/N): 
if /I "!CHOICE!"=="Y" (
    del "%TOOLSDIR%\uber-apk-signer-*.jar"
    goto :SIGNER_DOWNLOAD
)
goto :SIGNER_READY

:SIGNER_DOWNLOAD
echo Downloading uber-apk-signer...
powershell -Command "$r=Invoke-RestMethod 'https://api.github.com/repos/patrickfav/uber-apk-signer/releases/latest'; $a = $r.assets | Where-Object { $_.name -like '*.jar' }; Invoke-WebRequest -Uri $a.browser_download_url -OutFile ('%TOOLSDIR%\' + $a.name)"
for %%f in ("%TOOLSDIR%\uber-apk-signer-*.jar") do (
    set "SIGNER_JAR=%%~nxf"
    set "SIGNER_VERSION=%%~nxf"
)
set "SIGNER_VERSION=!SIGNER_VERSION:uber-apk-signer-=!"
set "SIGNER_VERSION=!SIGNER_VERSION:.jar=!"
set "SIGNER_LATEST=!SIGNER_VERSION!"
goto :SIGNER_READY

:SIGNER_READY
if not defined SIGNER_LATEST set "SIGNER_LATEST=!SIGNER_VERSION!"
goto :SELECT_PACKAGE

:SELECT_PACKAGE
echo.
echo ============================ Search Package ============================
echo.
set /p filter=Enter keyword to filter packages (leave empty to show all): 

echo.
echo ================== Fetching user-installed packages... ==================
echo.
adb shell pm list packages -3 > pkglist.txt

set i=0
for /f "tokens=2 delims=:" %%a in ('findstr /I "%filter%" pkglist.txt') do (
    set /a i+=1
    set "pkg[!i!]=%%a"
    echo !i!. %%a
)

echo.
set /p choice=Enter package number to pull: 
call set "PKG=!pkg[%choice%]!"

if "%PKG%"=="" (
    echo Invalid selection.
    goto :end
)

echo.
echo Selected package: %PKG%
echo.
set /p FOLDER=Enter folder name to save APKs: 
set "OUTDIR=%CD%\%FOLDER%"
set "OUTDIR=%OUTDIR:"=%"

if not exist "%OUTDIR%" (
    mkdir "%OUTDIR%"
)

echo.
echo ========================= Fetching APK paths... =========================
echo.
adb shell pm path %PKG% > apkpaths.txt
set pulled=0
for /f "tokens=2 delims=:" %%a in (apkpaths.txt) do (
    echo Pulling: %%a
    adb pull "%%a" "!OUTDIR!" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo Pulled successfully.
        set /a pulled+=1
    ) else (
        echo Failed to pull: %%a
    )
)

if !pulled! gtr 1 (
    echo.
    echo  ===================== Merging multiple APKs... =====================
    echo.
    java -jar "%TOOLSDIR%\apkeditor-!APKEDITOR_LATEST!.jar" m -i "!OUTDIR!" -o "!OUTDIR!\merged.apk"
    echo.
    echo ======================= Signing merged APK... =======================
    echo.
    java -jar "%TOOLSDIR%\uber-apk-signer-!SIGNER_LATEST!.jar" --apks "!OUTDIR!\merged.apk"
) else if !pulled! EQU 1 (
    for %%f in ("!OUTDIR!\*.apk") do set "SINGLE_APK=%%f"
    echo.
    echo =====================  APK Pulled: !SINGLE_APK! =====================
    echo.
    REM Uncomment below line if you want to sign single APK
    REM java -jar "%TOOLSDIR%\uber-apk-signer-!SIGNER_LATEST!.jar" --apks "!SINGLE_APK!"
)

:end
del pkglist.txt >nul 2>&1
del apkpaths.txt >nul 2>&1
echo.
echo ================== Apk Pulled And Signed Completed =====================
exit /b
