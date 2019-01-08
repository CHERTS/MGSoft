@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi XE2
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\Embarcadero\RAD Studio\9.0

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi16\Win32 -N0..\..\Lib\Delphi16\Win32 -NB..\..\Lib\Delphi16\Win32 -NO..\..\Lib\Delphi16\Win32 -NH..\..\Include\Delphi16\Win32 -LN..\..\Lib\Delphi16\Win32 -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi16\Win32 -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win -JL MGSoft160.dpk
%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi16\Win32 -N0..\..\Lib\Delphi16\Win32 -NB..\..\Lib\Delphi16\Win32 -NO..\..\Lib\Delphi16\Win32 -NH..\..\Include\Delphi16\Win32 -LN..\..\Lib\Delphi16\Win32 -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi16\Win32 -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell -JL dclMGSoft160.dpk
%IdeDir%\bin\dcc64.exe" -B -LE..\..\Bin\Delphi16\Win64 -N0..\..\Lib\Delphi16\Win64 -NB..\..\Lib\Delphi16\Win64 -NO..\..\Lib\Delphi16\Win64 -NH..\..\Include\Delphi16\Win64 -LN..\..\Lib\Delphi16\Win64 -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi16\Win64 -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win -JL MGSoft160.dpk
