@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "debug" &&(@echo on & set trace=echo) || (@echo off & set trace=rem)
set _VER_%0=1.0.0
@title %0 : -- version %_VER_%0% date: <ADD DATE>  
set #INTEG_%0=NOT_SET!
:: 
:: 
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by - AUTHOR - 
::  
::
::	<DATE> - AUTHOR
::		* File originally created
::	
::	Dependencies: 
::	
::		
::
:: Variables and Assignments
:: Passed From CONSOLE!
::		%1 		-> PARAM EXPECTED
::		%2		-> PARAM EXPECTED
::		...
::		%N		-> PARAM EXPECTED
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
	setlocal &  pushd %~dp0
	title %0
	cls
	if {%1}=={} (call :synerr %0& goto quit)
	@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "/?" && (call :synerr %0& goto quit)
	@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-?" && (call :synerr %0& goto quit)
	@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "--help" && (call :synerr %0& goto quit)
	@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-help" && (call :synerr %0& goto quit)	



	::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::  ***             Setings               ***       ::
	::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::

	set _IN1=%1
	set _IN2=%2
	set _default_exe_store=\\?????????\????

	:: EXAMPLE: 
	:: @echo %1 |find /i "file="&& for /f "delims== tokens=2" %%i in (%1) do (set _INFILE=%%i)
	:: Grabs the right side of a PARAMNAME=VALUE
	::




          	::::::::::::::::::::::::::::::::::::::::::::::::::::::
          	::  ***  Verify that dependencies are met ***       ::
          	::::::::::::::::::::::::::::::::::::::::::::::::::::::
          	::
          	::  Some dependencies are simple executables and can be copied down from a common source...
          	::  Other dependencies are larger applications that may require redistered dlls and can
          	::  not simply be copied down. In the case that this happens, and it is not possible to copy 
          	::  the executable, an error message will be displayed.
          	::
          
          	:CheckDependencies
          	set _dependencies=file1 file2 fileN

          		echo Check dependencies: "%_dependencies%"
          		for %%d in (%_dependencies%) do (call :VfyPath %%d)
          		if not {%RET%}=={0} (set _ERRMSG="An unrecoverable error has occured..." & call :DispErr !
          				) else (
          				goto MAIN)
          		endlocal & goto eof
          
          	:End_CheckDependencies	
          	::::::::::::::::::::::::::::::::::::::::::::::::::::::
          	::  ***  Verify that dependencies are met ***       ::
          	::::::::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::          Script Executive                ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MAIN

:exec_default

	::@call :DisplayBanner %0
	::@call :CopyFilesLocaly

	@goto quit




::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::           Sub Routines                   ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DisplayBanner
	:: This SUB simply displays a startup banner
	::
	::

	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ                              Start                                        บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo I am: %1
	echo.
	echo  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	echo.
	
	call :register  %0&goto eof
:End_DisplayBanner




:CopyFilesLocaly
	:: This SUB takes 2 parameters. These parameters are expected to be a
	:: source and a destination. The proper parameters will be applied to xcopy.
	:: 
	::

	setlocal 
	title %0
		if {%RET%}=={2} (endlocal & goto eof)
		if not exist %_local% MD %_local%
		xcopy "%_RemoteUNC%" %_local% /v /r /y /u /d /i
	
	call :register  %0& endlocal & goto eof

:End_CopyFilesLocaly


:ValidatePhysicalPath
	setlocal
		:: This SUB takes a single parameter. This parameter is expected to be a
		:: drive of folder to be tested for read and write. A RET variable of 1
		:: Will be returned on failure. 
		::
		echo.
		echo Validating physical source from DFS...
		:: Set the default return variable to failure...
		::
		set /a _RET=-1
		:: Only set RET to 0 (OK) if we can write and read to the location...
		::
		echo !>%1\%_ME:~1,30%.flg && type %1\%_ME:~1,30%.flg |find /i "!" && set /a _RET=0
		echo.
		if {%_RET%}=={0} (echo %1 is validated...) else (echo path %1 is not valid!)
	call :register  %0& endlocal & set _RET=%_RET% & goto eof
		
:End_ValidatePhysicalPath





:VfyPath
	setlocal
	:: Expand the path to where the executable is located if it exists,
	:: if it does not exist set the _LocalVfy to nul
	::
	set _LocalVfy=%~$PATH:1
	if {"%_LocalVfy%"}=={""} (
		echo File %1 is not in the PATH!
		echo trying to get it from the default exe repo...
		echo repo = %_default_exe_store%
		call :Get_dep %1
		) else (
		echo Dependency %1 satisfied....)

		if defined RET if not {%RET%}=={0} (set _ERRMSG="File %1 is not in the PATH!" & call :DispErr !)
	set _LocalVfy=
	call :register  %0& endlocal & goto eof
:End_VfyPath




:register
	:: Look in the registry "hklm\software\" to see if the subsection
	:: passed to this procedure has been run allready. If the passed argument is in the registry
	:: a return variable of RET=2 is passed back to parent procedure. If the argument is not foud a return variable
	:: of RET=0 is returned.
	setlocal
		set _item=%1
		reg query hklm\software\_aniara\%_ME%\%_IN1%--%_item% >nul 2>&1 && (set RET=2)|| (reg add hklm\software\_aniara\%_ME%\%_IN1%--%_item% >nul 2>&1 & set ret=0)
	endlocal & set RET=%RET%& goto eof
:End_Register



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::            ERROR handling Below          ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Get_dep
	setlocal
		set RET=0
		xcopy %_default_exe_store%\%1 %temp% ||set RET=-1
	endlocal &set RET=%RET%
	call :register  %0&goto eof

:synerr
	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ Syntax                                                             ...    บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo.
	echo.
	echo.
	echo. 
	echo.
	echo. 
	echo.
	echo.
	goto eof

:DispErr
	:: This SUB displays an error mesage in a standard way on a red screen. 
	:: It experct variable to be set: %_ERRMSG% 
	::

	cls
	if {%1}=={!} color 4e
	@title %0 -- !!%_ERRMSG%!!
	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ _VfyEnv                                                    ERROR...       บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo บ                                                                           บ
	echo บ                                                                           บ
	echo      %_ERRMSG%
	echo บ    Press [CONTROL] [C] to abort execution...                              บ
	echo บ                                                                           บ
	echo บ                                                                           บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	call :register  %0--%_ERRMSG%
	%_ERR_HANDLER%
	
	
:quit
endlocal & popd & for /f "delims== tokens=1" %%i in ('set _') do (set %%i=)


:eof
