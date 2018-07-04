@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "debug" &&(@echo on & set trace=echo) || (@echo off & set trace=rem)
:::::::::::::::           Header          ::::::::::::
::
set _VER_%0=1.0.0
@title %0 : -- version %_VER_%0% date: 8/14/2006 
set #INTEG_%0=NOT_SET!

:: --    _Reset_Share.cmd  --
:: Command Shell Script
:: 
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by Stephan Schutter - For File Fitness
::
::
::	8/14/2006 - Stephan Schutter
::		* File originally created.
::
::
::
::
::
::
:: Variables and Assignments
:: Passed From CONSOLE!
::		%0 		-> %Scriptname%
:: Common TS
::		%DEBUG% 	-> 1 value to turn on tracing
::		%ECHO% 		-> On Value to turn on echo
::		%RET% 		-> Argument Passing Value
::
:: 	Please list command files to be run here in the following format:
::
:: 	:TITLE
:: 	Description of the pupose of called command file.
:: 	call <path>\command.cmd or command...
::
::	if this script is modified, it MUST be loged!
::
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:INIT
	setlocal
	set _host=%computername%
	color 1f
	if exist mr del mr
	cls

	::**********   Settings *************
	::Enter the setting that affects this shell scripts' operation.
	::
	::_PERM = the permission to assign at the share level
        ::	  Perm can be: 
	::		Read
	::		Change 
	::		Full 
	::

	Set _PERM=full
	

:MAIN
	
	::@call :updown
	@call :read_share
	@call :reset_share
	endlocal & goto eof & color


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::          Sub Procedures                  ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:updown
	ping -n 1 %_host% >nul 2>&1|| ( sleep 10 &TITLE: MONITORING: %_host%: not online &goto updown) 
	goto eof
:end_updown

:read_share
	for /f "skip=5 tokens=1" %%i in ('net share') do (echo %%i|find /i /v "$" |find /v "The" |find /i /v ":" >>mr 2>&1)
	goto eof

:reset_share
	for /f %%h in (mr) do (
		echo %_host%: **********************************
		echo Found share: %%h
		echo Permissions.............
		SetACL.exe -on "\\%_host%\%%h" -ot shr -actn list -lst "f:tab" |find /v "The"
		echo.
		echo Reseting...........
		SetACL.exe -on "\\%_host%\%%h" -ot shr -actn ace -ace "n:everyone;p:full"
		echo. 
		echo Verifying............
		SetACL.exe -on "\\%_host%\%%h" -ot shr -actn list -lst "f:tab" |find /v "The"
		echo.
		echo.)
		
		type mr > sharedef.log & del mr
	goto eof

:syntax
	setlocal
	set ln4=syntax error!
	set ln5=Please use the folowing syntax:
	set ln6=%0 
	call :ovl
	endlocal & goto eof




:OVL
	cls & color 4e
	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ Error!                                                                    บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ                                                                           บ
	echo. 
	echo.           %ln1%                   
	echo.           %ln2%
	echo.           %ln3%
	echo.           %ln4%
	echo.           %ln5%
	echo.           %ln6%
	echo.           %ln7%
	echo.           %ln8%
	echo.                                                                            
	echo.                                                                            
	echo บ                                                                           บ
	echo บ                                                                           บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	pause
	color

:eof