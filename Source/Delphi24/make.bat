@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi Berlin
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\Embarcadero\Studio\18.0
rem del /Q/S MGSoft\*.*

if "%1"=="" goto all
call ..\Make.bat Delphi 24 %1
goto end
:all
call ..\Make.bat Delphi 24 WIN32
call ..\Make.bat Delphi 24 WIN64
:end
pause