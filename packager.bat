@echo off
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

REM Define el nombre del archivo ZIP con la versión
set "ClassicFilename=DisenchanterPlus-v%Build%-classic.zip"

REM Elimina el archivo ZIP anterior si existe
del "%Directory%Release\%ClassicFilename%.zip"

REM Crea el archivo ZIP excluyendo archivos de la lista de exclusiones
REM -x@packagerExclusions-Classic.lst: Excluye archivos especificados en el archivo de exclusiones
REM -xr@packagerExclusions-Classic.lst: Excluye directorios especificados de manera recursiva
REM -tzip: Define el formato de compresión como ZIP
REM -aoa: Sobrescribe archivos existentes (OverwriteAll)
7z a -x@packagerExclusions-Classic.lst -xr@packagerExclusions-Classic.lst -tzip ".\Release\%ClassicFilename%" "%Directory%" -aoa

REM Mensaje de confirmación
echo Paquete creado: %ClassicFilename%
