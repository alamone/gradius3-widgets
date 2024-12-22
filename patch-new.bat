@echo off

echo.
echo Gradius 3 Arcade NEW VERSION (JP) Widget Mod by alamone.
echo This mod adds various display widgets (numeric lives counter, current loop / stage).
echo.

if not exist "gradius3j\945_s12.e15" goto errorout
if not exist "gradius3j\945_s13.f15" goto errorout

echo Generating Gradius III widget patch...
echo.
combine-roms.exe gradius3j\945_s13.f15 gradius3j\945_s12.e15 945.bin
copy gradius3-new.asm+gradius3-common.asm gradius3.asm
asm68k /p gradius3.asm, 945-patched.bin
split-roms.exe 945-patched.bin gradius3j-modded\945_s13.f15 gradius3j-modded\945_s12.e15
echo.
echo Complete.  Results in "gradius3j-modded" folder.
goto ending

:errorout
echo Error: missing rom files.
echo.
echo Please copy Gradius III NEW ver. ROMs "945_s12.e15" and "945_s13.f15" into the "gradius3j" folder.
echo These files are not yet in MAME (as of v0.272).

:ending
echo.
pause
