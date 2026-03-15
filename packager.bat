echo off

for /f "delims=" %%x in (.version) do set Build=%%x
:continue

set "Build=%Build%"
set "Directory=%cd%"

echo Build: %Build%
echo Directory: %Directory%

set "ClassicFilename=DisenchanterPlus-v%Build%-classic.zip"

del "%Directory%Release\%ClassicFilename%.zip"

7z a -x@packagerExclusions-Classic.lst -xr@packagerExclusions-Classic.lst -tzip ".\Release\%ClassicFilename%" "%Directory%" -aoa
