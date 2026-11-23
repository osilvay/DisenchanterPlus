@echo off
REM ========================================
REM DisenchanterPlus Package Creator
REM Crea un archivo ZIP de distribución
REM ========================================
setlocal EnableExtensions DisableDelayedExpansion
pushd "%~dp0" || exit /b 1

set "SourceDir=%CD%"
for %%D in ("%SourceDir%") do set "AddonFolder=%%~nxD"
set "Version="
set /p "Version="<.version
if not defined Version (
    echo No se pudo leer la version de .version. >&2
    popd
    exit /b 1
)

set "CamelotZip=DisenchanterPlus-v%Version%-camelot.zip"
set "TbcZip=DisenchanterPlus-v%Version%-tbc.zip"
set "Ace3Url=https://codeload.github.com/WoWUIDev/Ace3/zip/refs/heads/master"

REM Prepara ambos ZIP en una carpeta temporal antes de publicar.
set "StageDir=%SourceDir%\Release\.ace3.%RANDOM%.%RANDOM%"
mkdir "%StageDir%" || (
    popd
    exit /b 1
)

set "Result=1"
call :download_ace3 || goto :cleanup
call :build_zip "%CamelotZip%" Camelot || goto :cleanup
call :build_zip "%TbcZip%" TBC || goto :cleanup

move /y "%StageDir%\%CamelotZip%" "Release\" >nul || goto :cleanup
move /y "%StageDir%\%TbcZip%" "Release\" >nul || goto :cleanup
echo Paquete creado: %CamelotZip%
echo Paquete creado: %TbcZip%
set "Result=0"

:cleanup
rd /s /q "%StageDir%"
if "%Result%"=="1" echo No se pudo completar el empaquetado. >&2
popd
exit /b %Result%

:download_ace3
echo Descargando AceGUI y AceConfig...
curl.exe -fsSL --max-time 60 -o "%StageDir%\Ace3.zip" "%Ace3Url%" || exit /b 1
7z x "%StageDir%\Ace3.zip" "-o%StageDir%" ^
    "Ace3-master/AceGUI-3.0/*" "Ace3-master/AceConfig-3.0/*" || exit /b 1

if not exist "%StageDir%\Ace3-master\AceGUI-3.0\AceGUI-3.0.xml" exit /b 1
if not exist "%StageDir%\Ace3-master\AceConfig-3.0\AceConfig-3.0.xml" exit /b 1

REM Usa la misma ruta interna que embeds.xml.
mkdir "%StageDir%\%AddonFolder%" || exit /b 1
move "%StageDir%\Ace3-master" "%StageDir%\%AddonFolder%\Libs" >nul || exit /b 1
exit /b 0

:build_zip
set "ZipName=%~1"
set "Exclusions=packagerExclusions-%~2.lst"
echo Empaquetando %ZipName%...

REM Excluye las dos copias del repositorio y agrega las descargadas.
7z a -tzip "-x@%Exclusions%" "-xr@%Exclusions%" ^
    "-xr!AceGUI-3.0" "-xr!AceConfig-3.0" ^
    "%StageDir%\%ZipName%" "%SourceDir%" || exit /b 1

pushd "%StageDir%" || exit /b 1
7z a -tzip "%ZipName%" "%AddonFolder%"
set "ZipResult=%errorlevel%"
popd
exit /b %ZipResult%
