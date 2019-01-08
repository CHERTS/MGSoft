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
rem del /Q/S MGSoft\*.*

call ..\Make.bat Delphi 14 WIN32
