@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "debug" &&(@echo on & set trace=echo) || (@echo off & set trace=rem)
set _VER_%0=1.0.0
@title %0 : -- version %_VER_%0% date: 9/13/2006 
set #INTEG_%0=NOT_SET!
:: 
:: 
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by - Stephan Schutter - For File Fitness
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
::		%1 		-> File name that maps user ID to home root path.
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
	setlocal & title %0
	cls
	if {%1}=={} (call :synerr %0& goto quit)
	@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "/?" && (call :synerr %0& goto quit)
	@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-?" && (call :synerr %0& goto quit)
	@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "--help" && (call :synerr %0& goto quit)
	@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-help" && (call :synerr %0& goto quit)	



	:: **********   Settings *************
	:: Enter the seting that affect this shell scripts' 
	:: actions here...
	::
        ::             Perm can be: R  Read
        ::                          C  Change (write)
        ::                          F  Full control
        ::                          P  Change Permissions (Special access)
        ::                          O  Take Ownership (Special access)
        ::                          X  EXecute (Special access)
        ::                          E  REad (Special access)
        ::                          W  Write (Special access)
        ::                          D  Delete (Special access)
	::
	::	_WINDOMAIN    = The netbios domain that the permissions will reference
	::	_ERR_HANDLER  = The action to take after a critical un-resolvable error has occurred 
	::	_dependencies = Files that this script relies on
	::	_default_exe_store = is the network location that executables can be downloaded from if required
	
	set _ME=%0&						::Save the name of this parent script...
	set _IN1=%1&					::First parameter store...
	set _IN2=%2&					::Second parameter store...
	set _HomeDriveLetter=P:&		::Drive letter to use for home and terminal server home...
	set _default_exe_store=\\CS01CORP\ROOT\FILES\Corp\IS\Dept\InfrastructureSystems\FilePrint\Scripts\Shell Programs\bin
	set _DS=dsp03na&				::Directory server to use to modify settings... 
	set _PERM=C&					::Permissions to use for the home folder...
	set _WINDOMAIN=NA&				::Name of the DOMAIN to look for users in...
	set _ERR_HANDLER=pause ^& exit&	::What to do when something really bombs!


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
          	set _dependencies=tscmd.exe dsquery.exe xcacls.exe

          		echo Check dependencies: "%_dependencies%"
          		for %%d in (%_dependencies%) do (call :VfyPath %%d)
          		if defined RET if not {%RET%}=={0} (set _ERRMSG="An unrecoverable error has occured..." & call :DispErr !)
			goto End_CheckDependencies

          
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
	if not exist %_IN1% (set _ERRMSG=File "%_IN1%" not found... & call :DispErr !&goto quit)
	@call :DisplayBanner %0
	for /f "tokens=1,2 delims=," %%a in (%_IN1%) do (call :ExecUser %%a %%b)
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
	cls
	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ                              Start                                        บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo I am: %1
	echo.
	echo  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	echo.
	
	goto eof
:End_DisplayBanner



:ExecUser
	setlocal
	set _userid=%1
	set _new_path=%2
		echo Setting %_userid% to point to %_new_path%\%_userid%...
		tscmd %_DS% %_userid% TerminalServerHomeDir %_new_path%\%_userid%
		tscmd %_DS% %_userid% TerminalServerHomeDirDrive %_HomeDriveLetter%
		dsquery user -samid %_userid% | dsmod user -hmdir %_new_path%\%_userid%
		dsquery user -samid %_userid% | dsmod user -hmdrv %_HomeDriveLetter%
		if not exist %_new_path%\%_userid% mkdir %_new_path%\%_userid%
		xcacls %_new_path%\%_userid% /E /G %_WINDOMAIN%\%_userid%:%_PERM% /Y >nul 2>&1 ||echo %%i >>homedirErr.log

	endlocal & goto eof

:End_ExecUser





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
	endlocal & goto eof
:End_VfyPath





::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::            ERROR handling Below          ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Get_dep
	setlocal
		set /a RET=0
		copy "%_default_exe_store%\%1" %windir% ||set /a RET=-1
	endlocal &set RET=%RET%& goto eof

:synerr
	cls
	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ Syntax                                                             ...    บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo.	 The syntax of this command is:
	echo.
	echo	 %1 ^<MapFile^>
	echo. 
	echo	 Where "MapFile" is the name of a comma separated file containing 
	echo	 User ID and Home Root Path. Example:
	echo.
	echo	 JoeSchmo, \\homeserver01\Home
	echo.
	goto eof

:DispErr
	:: This SUB displays an error mesage in a standard way on a red screen. 
	:: It experct variable to be set: %_ERRMSG% 
	::

	::cls
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
	%_ERR_HANDLER%
	
	
:quit
endlocal & popd & for /f "delims== tokens=1" %%i in ('set _') do (set %%i=)


:eof
