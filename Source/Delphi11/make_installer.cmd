@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi 2007
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\CodeGear\RAD Studio\5.0

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi11 -N0..\..\Lib\Delphi11 -NB..\..\Lib\Delphi11 -NO..\..\Lib\Delphi11 -NH..\..\Include\Delphi11 -LN..\..\Lib\Delphi11 -I..;..\Synapse -U..;..\Synapse -JL MGSoft110.dpk
%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi11 -N0..\..\Lib\Delphi11 -NB..\..\Lib\Delphi11 -NO..\..\Lib\Delphi11 -NH..\..\Include\Delphi11 -LN..\..\Lib\Delphi11 -I..;..\Synapse -U..;..\Synapse -JL dclMGSoft110.dpk
