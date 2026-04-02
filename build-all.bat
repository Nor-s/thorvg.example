@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
set "BUILD_SCRIPT=%SCRIPT_DIR%build-msys2-ucrt64.bat"

set "SUBPROJECTS=thorvg thorvg-main"
set "THREADS_OPTIONS=true false"

echo [thorvg] Starting parallel builds for all combinations...
echo.

set "COUNT=0"
for %%S in (%SUBPROJECTS%) do (
    for %%T in (%THREADS_OPTIONS%) do (
        set /a COUNT+=1
        echo [thorvg] Launching: %%S / threads=%%T
        start "[%%S][threads=%%T]" cmd /c call "%BUILD_SCRIPT%" %%S %%T ^& pause
    )
)

echo.
echo [thorvg] Launched %COUNT% parallel builds.
echo [thorvg] Each build runs in its own window.
