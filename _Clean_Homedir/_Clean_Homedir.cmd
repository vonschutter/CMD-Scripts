@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-debug" &&(@echo on & set trace=echo) || (@echo off & set trace=rem)
@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-dryrun" &&(set _dry=echo)
:::::::::::::::           Header          ::::::::::::
::
set _VER=1.0.0
@title %0 : -- version %_VER% :: %DATE% :: %TIME%
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
::		%RET% 		-> Argument Passing Value (success or failure)
::
:: 	Please list command files to be run here in the following format:
::
:: 	:TITLE
:: 	Description of the pupose of called command file.
:: 	call <path>\command.cmd or command...
::
::	if this script is modified, it MUST be logged!
::
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:INIT
	setlocal
	color 1f
	cls
	set _me=%0

	::	_WINDOMAIN    = The netbios domain that the permissions will reference
	::	_ERR_HANDLER  = The action to take after a critical un-resolvable error has occurred 
	::	_dependencies = Files that this script relies on
	::	_default_exe_store = is the network location that executables can be downloaded from if required
		
		set _dependencies=7z.exe dfscmd.exe
		set _WINDOMAIN=NA

	:: The default critical error handler: enter the commands that you want to run
	:: if a critical error occurs. For example if you want to run a script in case of an error then enter it here
	:: escaping any reserved characters with the caret symbol "^". 
	:: Syntax: command ^& command2 ^& commandn... 
	::
		set _ERR_HANDLER=pause ^& exit
		for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set _NEWDATE=%%d-%%b-%%c

		set _STAGE-ROOT=to-be-deleted
		set _STAGE-FOLDER=%_STAGE-ROOT%\%_NEWDATE%
			if not exist %_STAGE-FOLDER% mkdir %_STAGE-FOLDER%
		set _LOGDIR=%_STAGE-FOLDER%
			if not exist %_LOGDIR% mkdir %_LOGDIR% 	
		set _LOG=%_LOGDIR%\%0.log
		set _ERROR_LOG=%_LOGDIR%\error%0.log
		set _default_exe_store=\\cs01corp\root\files\Corp\IS\Dept\InfrastructureSystems\FilePrint\Scripts\Shell Programs\bin
		set RET=0
		echo Check dependencies: "%_dependencies%"
		for %%d in (%_dependencies%) do (call :VfyPath %%d >%_LOG% 2>&1 )
		if not {%RET%}=={0} (set _ERRMSG="An unrecoverable error has occured..." & call :DispErr !)
	goto MAIN
	
	

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::          Script Executive                ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:MAIN


	:: To logg error messages to another file:
	::		  >File01 2>file02

	call :Process_dir >%_LOG% 2>&1
	endlocal & goto eof



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::          Sub Procedures                  ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Process_dir
	call :DisplayBanner
	setlocal
	for /f "delims=#" %%i in ('dir /b /a:d-h') do (call :dir_handler %%i)
	endlocal & goto eof

:End_Process_dir



:DisplayBanner
	setlocal
	color 1e
	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ                              Start                                        บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo %DATE% : %TIME%
	echo I am: %_me% Invoked by: %CMDCMDLINE%
	set _location=%~dp0
	echo script location=%~dp0
	echo script location volume=%_location:~0,2%
	echo.
	echo Unused home directories will be stored in %_STAGE-FOLDER%
	echo Compression log will be stored in %_STAGE-FOLDER%\*_Compression.log
	echo Standard Log File is %_LOG%
	echo Errors will be logged in %_LOG%
	echo.
	echo To see a ridiculous amount of logging, call this script with -debug option
	echo To see what would happen on exec, call this script with the -dryrun option
	echo.
	echo  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	echo.
	endlocal & goto eof
:End_DisplayBanner



:dir_handler
	setlocal
	echo ______________________________________________________________
	echo. 
	echo 			[ %1 ]
	echo.
	set _userid=%1
	if {%_userid%}=={%_STAGE-ROOT%} (echo %_STAGE-ROOT% is the staging folder... Skipping. & popd & endlocal & goto eof )
	dsquery user -samid %_userid% |find /i "OU=Users"&& (echo A matching UserID was found in Active Directory for "%_userid%"...&echo Skipping folder "%_userid%"...) || (set _invalid_user=%_userid%& goto move_user)
	popd & endlocal & goto eof

		:move_user
		echo.
		echo A matching UserID could not be found in Active Directory for "%_userid%"...
		%trace% echo _userid="%_userid%", _invalid_user="%_invalid_user%",  
		echo Trying to move  %_invalid_user% to %_stage-folder%...
		%_dry% move %_invalid_user% %_STAGE-FOLDER% || (echo the folder %_invalid_user% could not be moved! Moving on to next item...& goto err_move_folder )
		echo entering folder "%_STAGE-FOLDER%"... 
		pushd %_STAGE-FOLDER%
		echo Compressing %_invalid_user% See  %_invalid_user%_Compression.log for details...
		%_dry% 7z a -r -y -tzip "%_invalid_user%.zip" "%_invalid_user%" >%_invalid_user%_Compression.log 
			IF ERRORLEVEL=255 echo User stopped the process...
			IF ERRORLEVEL=8 echo There was not enough memory to complete the operation...
			IF ERRORLEVEL=7 echo The compress command line had a syntax error in it...
			IF ERRORLEVEL=2 echo A fatal error occurred while compressing the folder  %_invalid_user%...
			IF ERRORLEVEL=1 echo Warning - Non fatal error. Some files were locked by other application during compressing...
			IF ERRORLEVEL=0 (%_dry% rmdir /S /Q %_invalid_user% >nul 2>&1)
		
	:err_move_folder
	set _invalid_user=
	set _userid=

	popd & endlocal & goto eof
:end_dir_handler




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
		xcopy "%_default_exe_store%\%1" "%windir%" ||set RET=-1
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




