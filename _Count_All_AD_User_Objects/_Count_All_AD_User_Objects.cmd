@echo off
:::::::::::::::           Header          ::::::::::::
::
set _VER_%0=1.0.0
set #INTEG_%0=NOT_SET!
:: 
:: 
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by Stephan Schutter - Brian R. Avanade
::  
::
::	9/7/2006 3:16PM - Stephan Schutter
::		* File originally created
::	
::	Dependencies: SEAlloc.exe Cluster.exe robocopy.exe dfscmd.exe
::	
::		
::
:: Variables and Assignments
::
:: Common TS
::		%DEBUG% -> 1 value to turn on tracing
::		%ECHO% -> On Value to turn on echo
::		%RET% -> Argument Passing Value
::
:: 	Please list command files to be run here in the following format:
::
:: 	:TITLE
:: 	Description of the purpose of called command file.
:: 	call <path>\command.cmd or command... 
::
::	if this script is modified, it MUST be logged!
::
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



	echo Building list of items in AD...
	echo This may take an extended period of time, depending on the number of objects. 
        for /f %%i in ('dsquery user -limit 0') do (call :counter )
	echo The total number of objects is: %_count%
	goto eof



:counter
	set /a _count+=1
	
:eof
