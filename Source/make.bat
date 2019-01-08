@echo off
rem **********************************************************************
rem *
rem * MGSoft
rem *
rem * Command line:
rem *   call ..\make.bat IDEName IDEVer
rem *   
rem * Parameters:
rem *   IDEName = (Delphi, CBuilder)
rem *   IDEVer = (6, 7, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26)
rem *   Platform = (WIN32, WIN64) WIN32 - default
rem **********************************************************************

rem Prepare ==============================================================
set IDEName=%1
set IDEVer=%2
set Platform=%3
set PrjName=MGSoft
set PrjNameL=mgsoft

if %Platform%A==WIN32A goto CompileWinProviders
if %Platform%A==WIN64A goto CompileWinProviders
:CompileWinProviders

pushd

rem Test IDEName
if %IDEName%A==DelphiA goto IDENameOK
if %IDEName%A==CBuilderA goto IDENameOK
echo Command line must be:
echo    call ..\Make.bat IDEName IDEVer
echo    IDEName = (Delphi, CBuilder)
goto Err
:IDENameOK

rem Test IDEVer
if %IDEVer%A==6A goto IDEVerOK
if %IDEVer%A==7A goto IDEVerOK
if %IDEVer%A==9A goto IDEVerOK
if %IDEVer%A==10A goto IDEVerOK
if %IDEVer%A==11A goto IDEVerOK
rem if %IDEVer%A==11A goto IDEVer11
if %IDEVer%A==12A goto IDEVerOK
if %IDEVer%A==14A goto IDEVerOK
if %IDEVer%A==15A goto IDEVerOK
if %IDEVer%A==16A goto IDEVerOK
if %IDEVer%A==17A goto IDEVerOK
if %IDEVer%A==18A goto IDEVerOK
if %IDEVer%A==19A goto IDEVerOK
if %IDEVer%A==20A goto IDEVerOK
if %IDEVer%A==21A goto IDEVerOK
if %IDEVer%A==22A goto IDEVerOK
if %IDEVer%A==23A goto IDEVerOK
if %IDEVer%A==24A goto IDEVerOK
if %IDEVer%A==25A goto IDEVerOK
if %IDEVer%A==26A goto IDEVerOK
echo Command line must be:
echo    call ..\Make.bat IDEName IDEVer
echo    IDEVer = (6, 7, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26)
goto Err

:IDEVer11:
set PkgVer=105
goto PkgVerOK

:IDEVerOK
set PkgVer=%IDEVer%0

:PkgVerOK

:PlatformWin64
if not %Platform%A==WIN64A goto PlatformWin32
set PlatformDir=Win64
goto PlatformOK

:PlatformWin32
set Platform=WIN32
set PlatformDir=Win32

:PlatformOK
set CompilerOptions=-B -LE. -LN. -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi%IDEVer%\%PlatformDir% -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win
set CompilerOptionsVCL=-B -LE. -LN. -I..;..\Synapse -U..;..\Synapse;..\..\Lib\Delphi%IDEVer%\%PlatformDir% -NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell

if %IDEVer%A==7A goto Delphi7CompileOptions
if %IDEVer%A==16A goto NotResetCompileOptions
if %IDEVer%A==17A goto NotResetCompileOptions
if %IDEVer%A==18A goto NotResetCompileOptions
if %IDEVer%A==19A goto NotResetCompileOptions
if %IDEVer%A==20A goto NotResetCompileOptions
if %IDEVer%A==21A goto NotResetCompileOptions
if %IDEVer%A==22A goto NotResetCompileOptions
if %IDEVer%A==23A goto NotResetCompileOptions
if %IDEVer%A==24A goto NotResetCompileOptions
if %IDEVer%A==25A goto NotResetCompileOptions
if %IDEVer%A==26A goto NotResetCompileOptions
set PlatformDir=.
set CompilerOptions=-B -LE. -LN. -I..;..\Synapse -U..;..\Synapse
set CompilerOptionsVCL=-B -LE. -LN. -I..;..\Synapse -U..;..\Synapse
goto NotResetCompileOptions

:Delphi7CompileOptions
set PlatformDir=.
set CompilerOptions=-B -LE. -LN. -I..;..\Synapse;..\TNTUnicode\Source;..\TNTUnicode\Design -U..;..\Synapse;..\TNTUnicode\Source;..\TNTUnicode\Design;..\..\Lib\Delphi%IDEVer%\%PlatformDir%
set CompilerOptionsVCL=-B -LE. -LN. -I..;..\Synapse;..\TNTUnicode\Source;..\TNTUnicode\Design -U..;..\Synapse;..\TNTUnicode\Source;..\TNTUnicode\Design;..\..\Lib\Delphi%IDEVer%\%PlatformDir%
set Compiler=%IdeDir%\Bin\dcc32.exe"

rem Compile TNTUnicode packages ===========================================
%Compiler% %CompilerOptions% TntUnicodeVcl_R70.dpk
@if errorlevel 1 goto Err
%Compiler% %CompilerOptionsVCL% TntUnicodeVcl_D70.dpk
@if errorlevel 1 goto Err
goto CompilerOK

:NotResetCompileOptions
rem Compile ==============================================================
if not %Platform%A==WIN32A goto Win64Compiler
set Compiler=%IdeDir%\Bin\dcc32.exe"
goto CompilerOK

:Win64Compiler
if not %Platform%A==WIN64A goto InvalidPlatform
set Compiler=%IdeDir%\Bin\dcc64.exe"
goto CompilerOK

:CompilerOK
rem Compile MGSoft packages =================================================
%Compiler% %CompilerOptions% MGSoft%PkgVer%.dpk
@if errorlevel 1 goto Err

if %Platform%A==WIN64A goto SkipDcl
%Compiler% %CompilerOptionsVCL% dclMGSoft%PkgVer%.dpk
@if errorlevel 1 goto Err

:SkipDcl
rem Copy files ===========================================================

if not exist ..\..\Bin\%IDEName%%IDEVer%\%PlatformDir% mkdir ..\..\Bin\%IDEName%%IDEVer%\%PlatformDir%
if exist *.bpl        move *.bpl               ..\..\Bin\%IDEName%%IDEVer%\%PlatformDir%
if not exist ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir% mkdir ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if exist *.dcu        move *.dcu               ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if exist ..\*.dcu     move ..\*.dcu            ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if exist ..\Synapse\*.dcu     move ..\Synapse\*.dcu            ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if exist *.dcp        move *.dcp               ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
copy ..\*.res         ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%

rem CBuilder files ===
if exist  *.bpi       move *.bpi               ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if exist  *.lib       move *.lib               ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if exist  *.a         move *.a                 ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if not exist ..\..\Include\%IDEName%%IDEVer%\%PlatformDir% mkdir ..\..\Include\%IDEName%%IDEVer%\%PlatformDir%
if exist  *.hpp       move *.hpp               ..\..\Include\%IDEName%%IDEVer%\%PlatformDir%
if exist  ..\*.hpp    move ..\*.hpp            ..\..\Include\%IDEName%%IDEVer%\%PlatformDir%

if %IDEVer%A==7A goto Delphi7Copy

goto end

:Delphi7Copy
rem Copy files ===========================================================
if not exist ..\..\Bin\%IDEName%%IDEVer%\%PlatformDir% mkdir ..\..\Bin\%IDEName%%IDEVer%\%PlatformDir%
if exist *.bpl        move *.bpl               ..\..\Bin\%IDEName%%IDEVer%\%PlatformDir%
if not exist ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir% mkdir ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if exist *.dcu        move *.dcu               ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if exist ..\TNTUnicode\Source\*.dcu        move ..\TNTUnicode\Source\*.dcu               ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
if exist ..\TNTUnicode\Design\*.dcu     move ..\TNTUnicode\Design\*.dcu            ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
copy *.res         ..\..\Lib\%IDEName%%IDEVer%\%PlatformDir%
goto end

:InvalidPlatform
echo Invalid Platform

:Err
pause

:end
popd
