@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "debug" &&(@echo on & set trace=echo) || (@echo off & set trace=rem)
@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-dryrun" &&(set _dry=echo)
:::::::::::::::           Header          ::::::::::::
::
set _VER=1.0.0
@title %0 : -- version %_VER% :: %DATE% :: %TIME%
set #INTEG_%0=NOT_SET!

:: --    rt.cmd  --
:: Command Shell Script
:: Used to add a route to a network through a tunnel. 
:: 
:: 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by Stephan Schutter - 
::
::
::	8/17/2006 - Stephan Schutter
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
::		%RET% 		-> Argument Passing Value (sucess or failure)
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
	::########## startup   ############
	:: make the operating environment local
	setlocal



	::########### settings ############ 
	:: Network mask of the destination you want to tunnel to...
	set _MASK=255.255.0.0

	:: Network mask of the destination you want to tunnel to...
	set _NET=209.98.0.0

	:: The network IP of the VPN you want to go via...
	set _VPN=10.2.0.0




::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::          Script Executive                ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


	::########### exec ################
	%_dry% for /f "tokens=1,2,3,4" %%a in ('route print') do (echo %%a|find /i "%_VPN%" &&(route add %_NET% mask %_MASK% %%d&& echo added route: %_NET% mask %_MASK% %%d))
	goto quit


:quit
	endlocal


:eof



