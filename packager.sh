#!/bin/bash
# ========================================
# DisenchanterPlus Package Creator
# Crea un archivo ZIP de distribución
# ========================================

# Lee la versión desde el archivo .version
Build=$(cat .version)

# Obtiene el directorio actual
Directory=$(pwd)

# Imprime información del build
echo "Build: $Build"
echo "Directory: $Directory"

# Define el nombre de los archivos ZIP con la versión (uno por flavor)
CamelotFilename="DisenchanterPlus-v${Build}-camelot.zip"
TBCFilename="DisenchanterPlus-v${Build}-tbc.zip"

# Elimina los archivos ZIP anteriores si existen
rm -f "${Directory}/Release/${CamelotFilename}" "${Directory}/Release/${TBCFilename}"

# Crea el directorio Release si no existe
mkdir -p "${Directory}/Release"

# Crea el archivo ZIP de Camelot excluyendo archivos de la lista
# -x@packagerExclusions-Camelot.lst: Excluye archivos especificados en el archivo
# -xr@packagerExclusions-Camelot.lst: Excluye directorios de manera recursiva
# -tzip: Define el formato de compresión como ZIP
7z a -x@packagerExclusions-Camelot.lst -xr@packagerExclusions-Camelot.lst -tzip "${Directory}/Release/${CamelotFilename}" "${Directory}"

# Crea el archivo ZIP de TBC con su propia lista (sin el TOC de Camelot)
7z a -x@packagerExclusions-TBC.lst -xr@packagerExclusions-TBC.lst -tzip "${Directory}/Release/${TBCFilename}" "${Directory}"

# Mensajes de confirmación
echo "Paquete creado: ${CamelotFilename}"
echo "Paquete creado: ${TBCFilename}"
