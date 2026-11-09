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

# Define el nombre del archivo ZIP con la versión
CamelotFilename="DisenchanterPlus-v${Build}-camelot.zip"

# Elimina el archivo ZIP anterior si existe
rm -f "${Directory}/Release/${CamelotFilename}"

# Crea el directorio Release si no existe
mkdir -p "${Directory}/Release"

# Crea el archivo ZIP excluyendo archivos de la lista
# -x@packagerExclusions-Camelot.lst: Excluye archivos especificados en el archivo
# -xr@packagerExclusions-Camelot.lst: Excluye directorios de manera recursiva
# -tzip: Define el formato de compresión como ZIP
7z a -x@packagerExclusions-Camelot.lst -xr@packagerExclusions-Camelot.lst -tzip "${Directory}/Release/${CamelotFilename}" "${Directory}"

# Mensaje de confirmación
echo "Paquete creado: ${CamelotFilename}"
