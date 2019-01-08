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

set IdeDir="%PROGRAMFILES%\Borland\Delphi7

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi7 -LN..\..\Bin\Delphi7 -N..\..\Lib\Delphi7 -I..;..\Synapse;..\TNTUnicode\Source -U..;..\Synapse MGSoft70.dpk
rem %IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi7 -LN..\..\Bin\Delphi7 -N..\..\Lib\Delphi7 -I..;..\Synapse;..\TNTUnicode\Source -U..;..\Synapse dclMGSoft70.dpk
