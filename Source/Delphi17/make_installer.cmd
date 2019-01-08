@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi XE3
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\Embarcadero\RAD Studio\10.0

%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi17\Win32 -NU..\..\Lib\Delphi17\Win32 -NB..\..\Lib\Delphi17\Win32 -NO..\..\Lib\Delphi17\Win32 -NH..\..\Include\Delphi17\Win32 -LN..\..\Lib\Delphi17\Win32 -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi17\Win32 -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win -JL MGSoft170.dpk
%IdeDir%\bin\dcc32.exe" -B -LE..\..\Bin\Delphi17\Win32 -NU..\..\Lib\Delphi17\Win32 -NB..\..\Lib\Delphi17\Win32 -NO..\..\Lib\Delphi17\Win32 -NH..\..\Include\Delphi17\Win32 -LN..\..\Lib\Delphi17\Win32 -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi17\Win32 -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell -JL dclMGSoft170.dpk
%IdeDir%\bin\dcc64.exe" -B -LE..\..\Bin\Delphi17\Win64 -NU..\..\Lib\Delphi17\Win64 -NB..\..\Lib\Delphi17\Win64 -NO..\..\Lib\Delphi17\Win64 -NH..\..\Include\Delphi17\Win64 -LN..\..\Lib\Delphi17\Win64 -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi17\Win64 -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win -JL MGSoft170.dpk
