#!/bin/bash
set -e
cd "$(dirname "$0")"
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

# Descarga los módulos de interfaz de Ace3 en un directorio temporal.
mkdir -p "${Directory}/Release"
Staging=$(mktemp -d "${Directory}/Release/.ace3.XXXXXXXX")
trap 'rm -rf "$Staging"' EXIT
curl -fsSL --max-time 60 -o "$Staging/Ace3.zip" "https://codeload.github.com/WoWUIDev/Ace3/zip/refs/heads/master"
7z x "$Staging/Ace3.zip" "-o$Staging" 'Ace3-master/AceGUI-3.0/*' 'Ace3-master/AceConfig-3.0/*'
test -f "$Staging/Ace3-master/AceGUI-3.0/AceGUI-3.0.xml"
test -f "$Staging/Ace3-master/AceConfig-3.0/AceConfig-3.0.xml"
PackageRoot=${Directory##*/}
mkdir "$Staging/$PackageRoot"
mv "$Staging/Ace3-master" "$Staging/$PackageRoot/Libs"

# Empaqueta cada flavor sin las copias antiguas de AceGUI y AceConfig.
7z a -x@packagerExclusions-Camelot.lst -xr@packagerExclusions-Camelot.lst '-xr!AceGUI-3.0' '-xr!AceConfig-3.0' -tzip "$Staging/$CamelotFilename" "$Directory"
7z a -x@packagerExclusions-TBC.lst -xr@packagerExclusions-TBC.lst '-xr!AceGUI-3.0' '-xr!AceConfig-3.0' -tzip "$Staging/$TBCFilename" "$Directory"

# Incluye las bibliotecas descargadas y publica los ZIP terminados.
(
  cd "$Staging"
  7z a -tzip "$CamelotFilename" "$PackageRoot"
  7z a -tzip "$TBCFilename" "$PackageRoot"
)
mv -f "$Staging/$CamelotFilename" "$Staging/$TBCFilename" "${Directory}/Release/"
echo "Paquete creado: ${CamelotFilename}"
echo "Paquete creado: ${TBCFilename}"
