@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi 2005
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\Borland\BDS\3.0

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi9 -LN..\..\Bin\Delphi9 -N..\..\Lib\Delphi9 -I..;..\Synapse -U..;..\Synapse MGSoft90.dpk
 %IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi9 -LN..\..\Bin\Delphi9 -N..\..\Lib\Delphi9 -I..;..\Synapse -U..;..\Synapse dclMGSoft90.dpk
