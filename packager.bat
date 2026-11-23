@echo off
setlocal DisableDelayedExpansion
pushd "%~dp0" || exit /b 1
REM ========================================
REM DisenchanterPlus Package Creator
REM Crea un archivo ZIP de distribución
REM ========================================

REM Lee la versión desde el archivo .version
for /f "delims=" %%x in (.version) do set Build=%%x
:continue

REM Define variables para el build y directorio actual
set "Build=%Build%"
set "Directory=%cd%"

REM Imprime información del build
echo Build: %Build%
echo Directory: %Directory%

REM Define el nombre de los archivos ZIP con la versión (uno por flavor)
set "CamelotFilename=DisenchanterPlus-v%Build%-camelot.zip"
set "TBCFilename=DisenchanterPlus-v%Build%-tbc.zip"

REM Descarga los módulos de interfaz de Ace3 en un directorio temporal.
if not exist "Release" mkdir "Release"
set "Staging=%Directory%\Release\.ace3.%RANDOM%.%RANDOM%"
mkdir "%Staging%" || goto :fail
curl.exe -fsSL --max-time 60 -o "%Staging%\Ace3.zip" "https://codeload.github.com/WoWUIDev/Ace3/zip/refs/heads/master" || goto :cleanup_error
7z x "%Staging%\Ace3.zip" "-o%Staging%" "Ace3-master/AceGUI-3.0/*" "Ace3-master/AceConfig-3.0/*" || goto :cleanup_error
if not exist "%Staging%\Ace3-master\AceGUI-3.0\AceGUI-3.0.xml" goto :cleanup_error
if not exist "%Staging%\Ace3-master\AceConfig-3.0\AceConfig-3.0.xml" goto :cleanup_error
for %%i in ("%Directory%") do set "PackageRoot=%%~nxi"
mkdir "%Staging%\%PackageRoot%" || goto :cleanup_error
move "%Staging%\Ace3-master" "%Staging%\%PackageRoot%\Libs" >nul || goto :cleanup_error

REM Empaqueta cada flavor sin las copias antiguas de AceGUI y AceConfig.
7z a -x@packagerExclusions-Camelot.lst -xr@packagerExclusions-Camelot.lst "-xr!AceGUI-3.0" "-xr!AceConfig-3.0" -tzip "%Staging%\%CamelotFilename%" "%Directory%" || goto :cleanup_error
7z a -x@packagerExclusions-TBC.lst -xr@packagerExclusions-TBC.lst "-xr!AceGUI-3.0" "-xr!AceConfig-3.0" -tzip "%Staging%\%TBCFilename%" "%Directory%" || goto :cleanup_error

REM Incluye las bibliotecas descargadas y publica los ZIP terminados.
pushd "%Staging%" || goto :cleanup_error
7z a -tzip "%CamelotFilename%" "%PackageRoot%" && 7z a -tzip "%TBCFilename%" "%PackageRoot%"
set "PackageStatus=%errorlevel%"
popd
if not "%PackageStatus%"=="0" goto :cleanup_error
move /y "%Staging%\%CamelotFilename%" "Release\" >nul || goto :cleanup_error
move /y "%Staging%\%TBCFilename%" "Release\" >nul || goto :cleanup_error
rd /s /q "%Staging%"
echo Paquete creado: %CamelotFilename%
echo Paquete creado: %TBCFilename%
popd
exit /b 0

:cleanup_error
rd /s /q "%Staging%"
:fail
popd
exit /b 1
