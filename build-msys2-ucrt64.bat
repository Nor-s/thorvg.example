@REM @echo off
@REM setlocal EnableExtensions

@REM set "SCRIPT_DIR=%~dp0"
@REM set "TARGET=%SCRIPT_DIR%subprojects\thorvg\build-msys2-ucrt64.bat"

@REM if not exist "%TARGET%" (
@REM     echo [thorvg.example] ERROR: Missing delegated script: %TARGET%
@REM     exit /b 1
@REM )

@REM call "%TARGET%"
@REM exit /b %ERRORLEVEL%

@echo off
setlocal EnableExtensions

@REM Usage: build-msys2-ucrt64.bat <thorvg_subproject> <threads>
@REM   thorvg_subproject: thorvg | thorvg-main | thorvg-main-feature | thorvg-feature-remove
@REM   threads:           true | false

if "%~1"=="" (
    echo [thorvg] ERROR: Missing argument: thorvg_subproject
    echo Usage: %~nx0 ^<thorvg_subproject^> ^<threads^>
    echo   thorvg_subproject: thorvg, thorvg-main, thorvg-main-feature, thorvg-feature-remove
    echo   threads:           true, false
    exit /b 1
)
if "%~2"=="" (
    echo [thorvg] ERROR: Missing argument: threads
    echo Usage: %~nx0 ^<thorvg_subproject^> ^<threads^>
    echo   thorvg_subproject: thorvg, thorvg-main, thorvg-main-feature, thorvg-feature-remove
    echo   threads:           true, false
    exit /b 1
)

set "THORVG_SUBPROJECT=%~1"
set "THREADS=%~2"

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%.") do set "THORVG_REPO_ROOT_WIN=%%~fI"

if defined THORVG_MSYS2_ROOT (
    set "MSYS2_ROOT=%THORVG_MSYS2_ROOT%"
) else (
    set "MSYS2_ROOT=C:\msys64"
)

set "BASH_EXE=%MSYS2_ROOT%\usr\bin\bash.exe"
set "UCRT64_BIN=%MSYS2_ROOT%\ucrt64\bin"
if defined THORVG_BUILD_DIR (
    set "BUILD_DIR=%THORVG_BUILD_DIR%"
) else (
    set "BUILD_DIR=build_msys2_ucrt64_%THORVG_SUBPROJECT%_%THREADS%"
)
set "MESON_OPTIONS=-Dthorvg_subproject=%THORVG_SUBPROJECT% -Dthreads=%THREADS%"
set "MSYS2_INSTALLER_URL=https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe"
set "MSYS2_PACKAGES=base-devel mingw-w64-ucrt-x86_64-binutils mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-pkgconf mingw-w64-ucrt-x86_64-vulkan-loader mingw-w64-ucrt-x86_64-libpng mingw-w64-ucrt-x86_64-libjpeg-turbo mingw-w64-ucrt-x86_64-libwebp mingw-w64-ucrt-x86_64-freetype"

echo [thorvg] Repository root: %THORVG_REPO_ROOT_WIN%
echo [thorvg] MSYS2 root: %MSYS2_ROOT%
echo [thorvg] Subproject: %THORVG_SUBPROJECT%
echo [thorvg] Threads: %THREADS%
echo [thorvg] Build dir: %BUILD_DIR%

@REM if not exist "%BASH_EXE%" (
@REM     call :install_msys2 || exit /b 1
@REM )

@REM if defined THORVG_MSYS2_DRY_RUN if not exist "%BASH_EXE%" exit /b 0

@REM if not exist "%BASH_EXE%" (
@REM     echo [thorvg] ERROR: MSYS2 bash was not found after installation.
@REM     exit /b 1
@REM )

call :run_bash "repo_root=$(cygpath -au \"$THORVG_REPO_ROOT_WIN\"); cd \"$repo_root\"; if [ -f %BUILD_DIR%/build.ninja ]; then meson setup %BUILD_DIR% %MESON_OPTIONS% --reconfigure; else meson setup %BUILD_DIR% %MESON_OPTIONS%; fi; ninja -C %BUILD_DIR% install" || exit /b 1
call :bundle_runtime_dlls || exit /b 1

echo [thorvg] MSYS2/UCRT64 build completed.
exit /b 0

@REM :install_msys2

@REM if /I not "%MSYS2_ROOT%"=="C:\msys64" (
@REM     echo [thorvg] ERROR: Automatic installation currently supports only C:\msys64.
@REM     echo [thorvg]        Set THORVG_MSYS2_ROOT to an existing installation or use the default path.
@REM     exit /b 1
@REM )

@REM set "MSYS2_INSTALLER=%TEMP%\msys2-base-x86_64-latest.sfx.exe"
@REM echo [thorvg] MSYS2 not found. Downloading official installer archive...
@REM powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -Uri '%MSYS2_INSTALLER_URL%' -OutFile '%MSYS2_INSTALLER%'" || exit /b 1

@REM echo [thorvg] Extracting MSYS2 to C:\msys64...
@REM powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%MSYS2_INSTALLER%' -ArgumentList '-y','-oC:\' -Wait -NoNewWindow" || exit /b 1

@REM del /q "%MSYS2_INSTALLER%" >nul 2>nul
@REM exit /b 0

:run_bash
setlocal
set "BASH_COMMAND=%~1"
set "CHERE_INVOKING=yes"
set "MSYSTEM=UCRT64"
set "MSYS2_PATH_TYPE=inherit"

if defined THORVG_MSYS2_DRY_RUN (
    echo [dry-run] "%BASH_EXE%" -lc "%BASH_COMMAND%"
    exit /b 0
)

echo [thorvg] bash -lc "%BASH_COMMAND%"
"%BASH_EXE%" -lc "%BASH_COMMAND%"
exit /b %ERRORLEVEL%

:bundle_runtime_dlls
set "TARGET_DIR=%THORVG_REPO_ROOT_WIN%\%BUILD_DIR%\src"

if defined THORVG_MSYS2_DRY_RUN (
    echo [dry-run] copy_runtime_dlls using objdump -p from "%UCRT64_BIN%" into "%TARGET_DIR%"
    echo [dry-run] expected runtime examples: libgcc_s_seh-1.dll libgomp-1.dll libwinpthread-1.dll libiconv-2.dll libstdc++-6.dll
    exit /b 0
)

if not exist "%UCRT64_BIN%\objdump.exe" (
    echo [thorvg] ERROR: Missing objdump.exe in %UCRT64_BIN%
    exit /b 1
)

if not exist "%TARGET_DIR%" (
    echo [thorvg] ERROR: Missing build output directory %TARGET_DIR%
    exit /b 1
)

echo [thorvg] Bundling MSYS2 runtime DLLs into %TARGET_DIR%
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$targetDir = [System.IO.Path]::GetFullPath('%TARGET_DIR%');" ^
  "$binDir = [System.IO.Path]::GetFullPath('%UCRT64_BIN%');" ^
  "$objdump = Join-Path $binDir 'objdump.exe';" ^
  "$systemPattern = '^(api-ms-win-|ext-ms-|ADVAPI32\.dll|COMCTL32\.dll|COMDLG32\.dll|CRYPT32\.dll|D3D11\.dll|DBGHELP\.dll|DXGI\.dll|GDI32\.dll|IMM32\.dll|KERNEL32\.dll|OLE32\.dll|OLEAUT32\.dll|OPENGL32\.dll|SETUPAPI\.dll|SHELL32\.dll|SHLWAPI\.dll|USER32\.dll|UCRTBASE\.dll|UUID\.dll|VERSION\.dll|WINMM\.dll|WS2_32\.dll)$';" ^
  "$queue = New-Object 'System.Collections.Generic.Queue[string]';" ^
  "$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase);" ^
  "Get-ChildItem -LiteralPath $targetDir -Filter '*.exe' | ForEach-Object { $queue.Enqueue($_.FullName) };" ^
  "while ($queue.Count -gt 0) {" ^
  "  $current = $queue.Dequeue();" ^
  "  if (-not (Test-Path -LiteralPath $current)) { continue };" ^
  "  $dlls = & $objdump -p $current 2>$null | Select-String 'DLL Name:' | ForEach-Object { (($_.ToString() -replace '^\s*DLL Name:\s*', '')).Trim() } | Sort-Object -Unique;" ^
  "  foreach ($dll in $dlls) {" ^
  "    if ($dll -match $systemPattern) { continue };" ^
  "    $source = Join-Path $binDir $dll;" ^
  "    if (-not (Test-Path -LiteralPath $source)) { continue };" ^
  "    $destination = Join-Path $targetDir $dll;" ^
  "    if ($seen.Add($dll)) {" ^
  "      Copy-Item -LiteralPath $source -Destination $destination -Force;" ^
  "      $queue.Enqueue($destination);" ^
  "      Write-Host ('[thorvg] copied runtime: ' + $dll);" ^
  "    }" ^
  "  }" ^
  "}" || exit /b 1

exit /b 0
