#!/bin/bash
# ========================================
# DisenchanterPlus Package Creator
# Crea un archivo ZIP de distribución
# ========================================

set -e

cd "$(dirname "$0")"
SourceDir=$PWD
AddonFolder=${SourceDir##*/}
Version=$(cat .version)
if [ -z "$Version" ]; then
  echo "No se pudo leer la version de .version." >&2
  exit 1
fi

CamelotZip="DisenchanterPlus-v${Version}-camelot.zip"
TbcZip="DisenchanterPlus-v${Version}-tbc.zip"
Ace3Url="https://codeload.github.com/WoWUIDev/Ace3/zip/refs/heads/master"

download_ace3() {
  echo "Descargando AceGUI y AceConfig..."
  curl -fsSL --max-time 60 -o "$StageDir/Ace3.zip" "$Ace3Url"
  7z x "$StageDir/Ace3.zip" "-o$StageDir" \
    'Ace3-master/AceGUI-3.0/*' 'Ace3-master/AceConfig-3.0/*'

  test -f "$StageDir/Ace3-master/AceGUI-3.0/AceGUI-3.0.xml"
  test -f "$StageDir/Ace3-master/AceConfig-3.0/AceConfig-3.0.xml"

  # Usa la misma ruta interna que embeds.xml.
  mkdir "$StageDir/$AddonFolder"
  mv "$StageDir/Ace3-master" "$StageDir/$AddonFolder/Libs"
}

build_zip() {
  local zip_name=$1
  local exclusions="packagerExclusions-$2.lst"
  echo "Empaquetando $zip_name..."

  # Excluye las dos copias del repositorio y agrega las descargadas.
  7z a -tzip "-x@$exclusions" "-xr@$exclusions" \
    '-xr!AceGUI-3.0' '-xr!AceConfig-3.0' \
    "$StageDir/$zip_name" "$SourceDir"

  (
    cd "$StageDir"
    7z a -tzip "$zip_name" "$AddonFolder"
  )
}

# Prepara ambos ZIP en una carpeta temporal antes de publicar.
mkdir -p Release
StageDir=$(mktemp -d "$SourceDir/Release/.ace3.XXXXXXXX")
trap 'rm -rf "$StageDir"' EXIT

download_ace3
build_zip "$CamelotZip" Camelot
build_zip "$TbcZip" TBC

mv -f "$StageDir/$CamelotZip" "$StageDir/$TbcZip" Release/
echo "Paquete creado: $CamelotZip"
echo "Paquete creado: $TbcZip"
