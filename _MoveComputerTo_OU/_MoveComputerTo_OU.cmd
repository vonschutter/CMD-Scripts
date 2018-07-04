@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "debug" &&(@echo on & set trace=echo) || (@echo off & set trace=rem)
:::::::::::::::           Header          ::::::::::::
:: 
:: 
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by Stephan Schutter - For Org Fitness
::  
::
::	9/7/2006 3:16PM - Stephan Schutter
::	
::	Dependencies: 
::	
::		
::
:: Variables and Assignments
:: Passed From CONSOLE!
::		%0 		-> %Scriptname%
::		%1		-> *.INI file to read settings from.
::
:: Common TS
::		%DEBUG% -> 1 value to turn on tracing
::		%ECHO% -> On Value to turn on echo
::		%RET% -> Argument Passing Value
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

:::::::::::::::  Startup ::::::::::::::::::::::::::::::::::

:INIT 
	setlocal & pushd %~dp0 & title %0
	
	for /f "tokens=2 delims=." %%v in ("%USERDNSDOMAIN%") do (set _INETDOMAIN=%%v)
	set _INETSUFFIX=%USERDNSDOMAIN:~-3%


	::**********   Settings *************
	::Enter the setting that affects this shell scripts' operation.
	::
        ::	 
	:: _OUPARENT0 = first OU parent
	:: _OUPARENT1 = second OU parent
	:: _OUPARENT2 = thisrd OU parent
	
	set _OUPARENT0=Workstations
	set _OUPARENT1=Central
	set _OUPARENT2=XP
	set _OUPARENT3=
	set _OUPARENT4=
	set _OUPARENT5=


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::						::::::::::::::::::::::
::::::::::::::		Script Executive		::::::::::::::::::::::
::::::::::::::						::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:exec_default
	
	
	@call :Move_ComputerToCorrectOU
	goto quit








:Move_ComputerToCorrectOU
	::setlocal 
	title %0
	for /f "delims== tokens=1" %%i in ('set _OUPARENT') do (call :BLDCMD %%i)
	echo dsquery computer -samid *%computername%* ^| dsmove -newparent "%%_CMD_OUPARENT5%%%%_CMD_OUPARENT4%%%%_CMD_OUPARENT3%%%%_CMD_OUPARENT2%%%%_CMD_OUPARENT1%%%%_CMD_OUPARENT0%%dc=%_INETDOMAIN%,dc=%_INETSUFFIX%">x.cmd&&call x.cmd&&del x.cmd
	
	endlocal & goto eof
		:BLDCMD
		set _CMD%1=ou=%1,
	goto eof
	
	
:quit
	endlocal & popd
:eof