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
ClassicFilename="DisenchanterPlus-v${Build}-classic.zip"

# Elimina el archivo ZIP anterior si existe
rm -f "${Directory}/Release/${ClassicFilename}"

# Crea el directorio Release si no existe
mkdir -p "${Directory}/Release"

# Crea el archivo ZIP excluyendo archivos de la lista
# -x@packagerExclusions-Classic.lst: Excluye archivos especificados en el archivo
# -xr@packagerExclusions-Classic.lst: Excluye directorios de manera recursiva
# -tzip: Define el formato de compresión como ZIP
7z a -x@packagerExclusions-Classic.lst -xr@packagerExclusions-Classic.lst -tzip "${Directory}/Release/${ClassicFilename}" "${Directory}"

# Mensaje de confirmación
echo "Paquete creado: ${ClassicFilename}"
