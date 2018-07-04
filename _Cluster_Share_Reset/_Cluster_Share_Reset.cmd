@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "debug" &&(@echo on & set trace=echo) || (@echo off & set trace=rem)
:::::::::::::::           Header          ::::::::::::
::
set _VER_%0=1.1.0
@title %0 : -- version %_VER_%0% date: 8/30/2006 
set #INTEG_%0=NOT_SET!

:: --    _Cluster_Share_Reset.cmd  --
:: Command Shell Script
:: 
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by Stephan Schutter - For File Fitness
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
	color 1f
	if exist mr del mr
	cls

	:: **********   Settings *************
	:: Enter the seting that affect this shell scripts' 
	:: actions here...
	::
        ::             Perm can be: R  Read
        ::                          C  Change (write)
        ::                          F  Full control
        ::                          P  Change Permissions (Special access)
        ::                          W  Write (Special access)
	::
	::  _WINDOMAIN    = The netbios domain that the permissions will reference
	::  _ERR_HANDLER  = The action to take after a critical un-resolvable error has occurred 
	::  _dependencies = Files that this script relies on

		
		
	set _PERM=F
	set _WINDOMAIN=%computername%
	set _UserOrGroup=Everyone
	set _ERR_HANDLER=pause ^& exit
	set _dependencies=cluster.exe
	set _default_exe_store=\\cs01corp\root\files\corp\IS\Dept\InfrastructureSystems\FilePrint\BIN
	set RET=0






:main
	for /f "skip=3 tokens=1, 2, 3" %%a in ('cluster . res') do (echo %%a %%b %%c|find /v ":" |find /v "- IP" |find /v "- Network" |find /v "----">mr &&call :exec)
	del mr & endlocal & goto eof
      
:exec
	::Add per-share cluster command here!
	for /f "tokens=*" %%i in (mr) do (cluster . res "%%i" /listdep
	cluster . res "%%i" /priv security=%_WINDOMAIN%\%_UserOrGroup%,grant,%_PERM%:security)
      	goto eof



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::          Sub Procedures                  ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




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
	goto eof 


:end

:eof