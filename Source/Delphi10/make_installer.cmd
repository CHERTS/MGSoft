@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi 2006
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\Borland\BDS\4.0

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi10 -N0..\..\Lib\Delphi10 -NB..\..\Lib\Delphi10 -NO..\..\Lib\Delphi10 -NH..\..\Include\Delphi10 -LN..\..\Lib\Delphi10 -I..;..\Synapse -U..;..\Synapse -JL MGSoft100.dpk
%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi10 -N0..\..\Lib\Delphi10 -NB..\..\Lib\Delphi10 -NO..\..\Lib\Delphi10 -NH..\..\Include\Delphi10 -LN..\..\Lib\Delphi10 -I..;..\Synapse -U..;..\Synapse -JL dclMGSoft100.dpk
