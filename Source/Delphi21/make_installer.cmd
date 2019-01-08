@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi XE7
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\Embarcadero\Studio\15.0

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi21\Win32 -NU..\..\Lib\Delphi21\Win32 -NB..\..\Lib\Delphi21\Win32 -NO..\..\Lib\Delphi21\Win32 -NH..\..\Include\Delphi21\Win32 -LN..\..\Lib\Delphi21\Win32 -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi21\Win32 -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win -JL MGSoft210.dpk
%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi21\Win32 -NU..\..\Lib\Delphi21\Win32 -NB..\..\Lib\Delphi21\Win32 -NO..\..\Lib\Delphi21\Win32 -NH..\..\Include\Delphi21\Win32 -LN..\..\Lib\Delphi21\Win32 -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi21\Win32 -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell -JL dclMGSoft210.dpk
%IdeDir%\bin\dcc64.exe" -B -LE..\..\Bin\Delphi21\Win64 -NU..\..\Lib\Delphi21\Win64 -NB..\..\Lib\Delphi21\Win64 -NO..\..\Lib\Delphi21\Win64 -NH..\..\Include\Delphi21\Win64 -LN..\..\Lib\Delphi21\Win64 -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi21\Win64 -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win -JL MGSoft210.dpk
