@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "debug" &&(@echo on & set trace=echo) || (@echo off & set trace=rem)
:::::::::::::::           Header          ::::::::::::
::
set _VER_%0=1.0.0
@title %0 : -- version %_VER_%0% date: 8:55 AM 8/17/2006
set #INTEG_%0=NOT_SET!

:: --    CheckHomedirConfig.cmd  --
:: Command Shell Script
:: Used to process a home folder and add the user that matches the name of the users home folder
:: with the permissions the user is supposed to have...
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by Stephan Schutter - For File Fitness
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
	setlocal
	color 1f
	cls	

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
		
		
	set _PERM=C
	set _WINDOMAIN=NA
		:: The default critical error handler: enter the commands that you want to run
		:: if a critical error occurs. For example if you want to run a script in case of an error then enter it here
		:: escaping any reserved characters with the carret symbol "^". 
		:: Syntax: command ^& command2 ^& commandn... 
		::
	set _ERR_HANDLER=pause ^& exit
	set _dependencies=xcacls.exe fileacl.exe
	set _default_exe_store=\\cs01corp\root\files\corp\IS\Dept\InfrastructureSystems\FilePrint\BIN
	set RET=0
	echo Check dependencies: "%_dependencies%"
	for %%d in (%_dependencies%) do (call :VfyPath %%d)
	if not {%RET%}=={0} (set _ERRMSG="An unrecoverable error has occured..." & call :DispErr !
			) else (
			goto MAIN)
	endlocal & goto eof
	

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::          Script Executive                ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:MAIN
	@call :Process_dir
	endlocal & goto eof



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::          Sub Procedures                  ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Process_dir
	setlocal
	for /f %%i in ('dir /b /a:d') do (
	echo Now Processing %%i...
	xcacls %%i /E /G %_WINDOMAIN%\%%i:%_PERM% /Y >nul 2>&1 ||echo %%i >>homedirErr.log
	xcacls %%i /E /G %_WINDOMAIN%\%%i-a:%_PERM% /Y >nul 2>&1 ||echo %%i >>homedirErr-a.log
	fileacl %%i /inherit /Files /Sub >nul 2>&1 ||echo %%i >>resetErr.log)
	endlocal
	goto eof



:VfyPath
	setlocal
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
::::::::::::::						::::::::::::::::::::::
::::::::::::::		ERROR handling Below	 	::::::::::::::::::::::
::::::::::::::						::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Get_dep
	setlocal
		set RET=0
		xcopy %_default_exe_store%\%1 %temp% ||set RET=-1
	endlocal &set RET=%RET%
	goto eof

:DispErr
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
	%_ERR_HANDLER%

:end

:eof




