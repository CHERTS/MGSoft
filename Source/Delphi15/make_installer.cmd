@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi XE
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\Embarcadero\RAD Studio\8.0

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi15 -N0..\..\Lib\Delphi15 -NB..\..\Lib\Delphi15 -NO..\..\Lib\Delphi15 -NH..\..\Include\Delphi15 -LN..\..\Lib\Delphi15 -I..;..\Synapse -U..;..\Synapse -JL MGSoft150.dpk
%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi15 -N0..\..\Lib\Delphi15 -NB..\..\Lib\Delphi15 -NO..\..\Lib\Delphi15 -NH..\..\Include\Delphi15 -LN..\..\Lib\Delphi15 -I..;..\Synapse -U..;..\Synapse -JL dclMGSoft150.dpk
