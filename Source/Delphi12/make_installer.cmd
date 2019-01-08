@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi 2009
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\CodeGear\RAD Studio\6.0

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi12 -N0..\..\Lib\Delphi12 -NB..\..\Lib\Delphi12 -NO..\..\Lib\Delphi12 -NH..\..\Include\Delphi12 -LN..\..\Lib\Delphi12 -I..;..\Synapse -U..;..\Synapse -JL MGSoft120.dpk
%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi12 -N0..\..\Lib\Delphi12 -NB..\..\Lib\Delphi12 -NO..\..\Lib\Delphi12 -NH..\..\Include\Delphi12 -LN..\..\Lib\Delphi12 -I..;..\Synapse -U..;..\Synapse -JL dclMGSoft120.dpk
