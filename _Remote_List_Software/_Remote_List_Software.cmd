@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "debug" &&(@echo on & set trace=echo) || (@echo off & set trace=rem)
:::::::::::::::           Header          ::::::::::::
::
set _VER_%0=1.0.0
@title %0 : -- version %_VER_%0% date: 8/25/2006
set #INTEG_%0=NOT_SET!

:: --    _Reset_Share.cmd  --
:: Command Shell Script
:: 
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by Stephan Schutter - For Org Fitness
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
	setlocal & pushd %~dp0 & title %0
	if {%1}=={} (goto syntax) else (if {%1}=={read.sdb} (goto read.sdb) else (set _hostname=%1&goto main))
	goto eof


:MAIN
	for /f "tokens=3*" %%a in ('call %0 read.sdb') do (call :write.scr %%a%%b)
	endlocal & goto eof 



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::          Sub Procedures                  ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:write.scr
	echo %*
	goto eof


:read.sdb
	:: Read the remote machines software database...
	ping -n 1 %_hostname% >nul 2>&1|| goto err_nohost
	for /f %%i in ('reg query \\%_hostname%\hklm\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') do (reg query %%i 2>nul |find /i "DisplayName" |find /v /i "ParentDisplayName")
	goto eof

:syntax 
	echo ^<%0^>
	echo.
	echo 	What computer on the network do you want me to look at??? 
	echo 	You have to tell me what machine you want me to list instaled software for!
	echo. 
	echo 	like this: %0 ^<hostname^>
	goto quit

:err_nohost
	echo That hostname (%_hostname%) does not exist or is not on the network at this time. 
	goto quit

:quit
	endlocal & popd &goto eof

:eof