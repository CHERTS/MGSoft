@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi 2010
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\Embarcadero\RAD Studio\7.0

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi14 -N0..\..\Lib\Delphi14 -NB..\..\Lib\Delphi14 -NO..\..\Lib\Delphi14 -NH..\..\Include\Delphi14 -LN..\..\Lib\Delphi14 -I..;..\Synapse -U..;..\Synapse -JL MGSoft140.dpk
%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi14 -N0..\..\Lib\Delphi14 -NB..\..\Lib\Delphi14 -NO..\..\Lib\Delphi14 -NH..\..\Include\Delphi14 -LN..\..\Lib\Delphi14 -I..;..\Synapse -U..;..\Synapse -JL dclMGSoft140.dpk
