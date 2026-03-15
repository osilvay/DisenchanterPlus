echo off

for /f "delims=" %%x in (.version) do set Build=%%x
:continue

set "Build=%Build%"
set "Directory=%cd%"

echo Build: %Build%
echo Directory: %Directory%

set "CataFilename=DisenchanterPlus-v%Build%-cata.zip"
set "ClassicFilename=DisenchanterPlus-v%Build%-classic.zip"

del "%Directory%Release\%ClassicFilename%.zip"
del "%Directory%Release\%CataFilename%.zip"

7z a -x@packagerExclusions-Classic.lst -xr@packagerExclusions-Classic.lst -tzip ".\Release\%ClassicFilename%" "%Directory%" -aoa
7z a -x@packagerExclusions-Cata.lst -xr@packagerExclusions-Cata.lst -tzip ".\Release\%CataFilename%" "%Directory%" -aoa
