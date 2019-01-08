@echo off
rem **********************************************************************
rem *
rem * MGSoft for Delphi 7
rem *
rem **********************************************************************

rem --- Win64 compatibility ---
if "%ProgramFiles(x86)%"=="" goto DoWin32
set PROGRAMFILES=%ProgramFiles(x86)%
:DoWin32

set IdeDir="%PROGRAMFILES%\Borland\Delphi7
call ..\Make.bat Delphi 7
