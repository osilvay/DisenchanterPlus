echo off

for /f "delims=" %%x in (.version) do set Build=%%x
:continue

set "Build=%Build%"
set "Directory=%cd%\"

echo Build: %Build%
echo Directory: %Directory%

rem 7z a -tzip DisenchanterPlus.zip *.txt -x!temp.*

7z a -tzip DisenchanterPlus.zip %Directory%* -r -xr!bin -xr!.vscode -xr!.git -xr!Doc -xr!Releases -x!*.gitignore -x!packager.bat -x!pkgmeta.yaml -x!.version -x!*.zip