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

REM Define el nombre de los archivos ZIP con la versión (uno por flavor)
set "CamelotFilename=DisenchanterPlus-v%Build%-camelot.zip"
set "TBCFilename=DisenchanterPlus-v%Build%-tbc.zip"

REM Elimina los archivos ZIP anteriores si existen
del "%Directory%\Release\%CamelotFilename%"
del "%Directory%\Release\%TBCFilename%"

REM Crea el archivo ZIP excluyendo archivos de la lista de exclusiones
REM -x@packagerExclusions-Camelot.lst: Excluye archivos especificados en el archivo de exclusiones
REM -xr@packagerExclusions-Camelot.lst: Excluye directorios especificados de manera recursiva
REM -tzip: Define el formato de compresión como ZIP
REM -aoa: Sobrescribe archivos existentes (OverwriteAll)
7z a -x@packagerExclusions-Camelot.lst -xr@packagerExclusions-Camelot.lst -tzip ".\Release\%CamelotFilename%" "%Directory%" -aoa

REM Paquete TBC: usa su propia lista de exclusiones (sin el TOC de Camelot)
7z a -x@packagerExclusions-TBC.lst -xr@packagerExclusions-TBC.lst -tzip ".\Release\%TBCFilename%" "%Directory%" -aoa

REM Mensajes de confirmación
echo Paquete creado: %CamelotFilename%
echo Paquete creado: %TBCFilename%
