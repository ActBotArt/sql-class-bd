@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

title Git Auto Setup

:: Check if Git is already installed
git --version >nul 2>&1
if %errorlevel% equ 0 (
    :: Check current version
    for /f "tokens=3" %%i in ('git --version') do set CURRENT_VERSION=%%i
    set TARGET_VERSION=2.49.0.windows.1
    
    if "!CURRENT_VERSION!"=="!TARGET_VERSION!" (
        echo Git is up to date
        goto :clone_repo
    ) else (
        echo Updating Git...
        goto :update_git
    )
) else (
    echo Installing Git...
    goto :install_git
)

:update_git
set TEMP_DIR=%TEMP%\git_update
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

set GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.49.0.windows.1/Git-2.49.0-64-bit.exe
set GIT_INSTALLER=%TEMP_DIR%\Git-updater.exe

echo Downloading update...
powershell -Command "$ProgressPreference = 'Continue'; try { Invoke-WebRequest -Uri '%GIT_URL%' -OutFile '%GIT_INSTALLER%' -UseBasicParsing; Write-Host 'Download completed'; exit 0 } catch { Write-Host 'Download failed'; exit 1 }"

if not exist "%GIT_INSTALLER%" goto :clone_repo

echo Installing update...
start /wait "" "%GIT_INSTALLER%" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS >nul 2>&1

set PATH=%PATH%;C:\Program Files\Git\bin;C:\Program Files\Git\cmd

if exist "%GIT_INSTALLER%" del /q "%GIT_INSTALLER%"
if exist "%TEMP_DIR%" rmdir /q "%TEMP_DIR%"

goto :clone_repo

:install_git
set TEMP_DIR=%TEMP%\git_install
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

set GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.49.0.windows.1/Git-2.49.0-64-bit.exe
set GIT_INSTALLER=%TEMP_DIR%\Git-installer.exe

echo Downloading Git...
powershell -Command "$ProgressPreference = 'Continue'; try { Invoke-WebRequest -Uri '%GIT_URL%' -OutFile '%GIT_INSTALLER%' -UseBasicParsing; Write-Host 'Download completed'; exit 0 } catch { Write-Host 'Download failed'; exit 1 }"

if not exist "%GIT_INSTALLER%" (
    echo Download failed. Visit: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo Installing Git...
start /wait "" "%GIT_INSTALLER%" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS >nul 2>&1

set PATH=%PATH%;C:\Program Files\Git\bin;C:\Program Files\Git\cmd

if exist "%GIT_INSTALLER%" del /q "%GIT_INSTALLER%"
if exist "%TEMP_DIR%" rmdir /q "%TEMP_DIR%"

timeout /t 2 /nobreak >nul
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Installation failed
    pause
    exit /b 1
)

:clone_repo
echo Setting up repository...

for /f "tokens=3*" %%i in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Desktop 2^>nul') do set DESKTOP_PATH=%%i %%j
if not defined DESKTOP_PATH set DESKTOP_PATH=%USERPROFILE%\Desktop

cd /d "%DESKTOP_PATH%"

if exist "sql-class-bd" rmdir /s /q "sql-class-bd" >nul 2>&1

echo Cloning repository...
git clone https://github.com/ActBotArt/sql-class-bd.git >nul 2>&1

if %errorlevel% equ 0 (
    echo Complete! Opening folder...
    start "" explorer "%DESKTOP_PATH%\sql-class-bd"
) else (
    echo Clone failed - check internet connection
)

timeout /t 2 /nobreak >nul