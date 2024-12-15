echo off

for /f "delims=" %%x in (.version) do set Build=%%x
:continue

set "Build=%Build%"
set "Directory=%cd%\"

echo Build: %Build%
echo Directory: %Directory%

set "CataFilename=DisenchanterPlus-v%Build%-cata.zip"
set "ClassicFilename=DisenchanterPlus-v%Build%-classic.zip"

rem 7z a -tzip DisenchanterPlus.zip *.txt -x!temp.*
rem F:\PROYECTOS\PERSONAL\World of Warcraft\_classic_era_\Interface\AddOns\DisenchanterPlus\

del "%Directory%*.zip"

7z a -x!DisenchanterPlus-Classic.toc -x@packagerExclusions.lst -xr@packagerExclusions.lst -tzip %CataFilename% "%Directory%*" -aoa
7z a -x!DisenchanterPlus-Cata.toc -x@packagerExclusions.lst -xr@packagerExclusions.lst -tzip %ClassicFilename% "%Directory%*" -aoa
