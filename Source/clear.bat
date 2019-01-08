@echo off

set dirname=.

rd /S /Q %dirname%\__history
del /S %dirname%\*.identcache
del /S %dirname%\*.dproj.local
del /S %dirname%\*.local
del /S %dirname%\*.tvsconfig
del /S %dirname%\*.~*
del /S %dirname%\descript.ion
del /S %dirname%\*.ddp
del /S %dirname%\*.map
del /S %dirname%\*.dcu
del /S %dirname%\*.hpp
del /S %dirname%\*.dcp
del /S %dirname%\*.bpi
del /S %dirname%\*.bpl
del /S %dirname%\*.lib
