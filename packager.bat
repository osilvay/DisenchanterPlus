echo off

for /f "delims=" %%x in (.version) do set Build=%%x
:continue

set "Build=%Build%"
set "Directory=%cd%"

echo Build: %Build%
echo Directory: %Directory%

set "CataFilename=DisenchanterPlus-v%Build%-cata.zip"
set "ClassicFilename=DisenchanterPlus-v%Build%-classic.zip"

del "%Directory%Releases\%ClassicFilename%.zip"
del "%Directory%Releases\%CataFilename%.zip"

7z a -x!DisenchanterPlus-Cata.toc -x@packagerExclusions.lst -xr@packagerExclusions.lst -tzip ".\Releases\%ClassicFilename%" "%Directory%" -aoa
7z a -x!DisenchanterPlus-Classic.toc -x@packagerExclusions.lst -xr@packagerExclusions.lst -tzip ".\Releases\%CataFilename%" "%Directory%" -aoa
