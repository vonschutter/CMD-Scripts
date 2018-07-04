@echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-debug" &&(@echo on & set trace=echo & set debug=1 ^& pause) || (@echo off & set trace=rem)
:::::::::::::::           Header          ::::::::::::
::
set _VER_%0=1.0.0
set #INTEG_%0=NOT_SET!
:: 
:: 
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Developed by Stephan Schutter - For File Fitness
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
:: Passed From CONSOLE!
::		%1 		-> DFS path to move
::		%2		-> UNC path to move to
::		or
::		%1		-> file listing the above 2 elements
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

:::::::::::::::  Startup ::::::::::::::::::::::::::::::::::

:INIT 
	:::::::::::::::::::::::::::::::::::::::::::::::::::
	::	Script startup components; tasks that always 
	::	need to be done when the initializes. 
	::
	setlocal &  pushd %~dp0 
	%debug%
	cls
	if {%1}=={} (call :synerr %0& goto quit)
	echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-dryrun" >nul 2>&1 && (set _dry=echo)
	echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "?" >nul 2>&1 && (call :synerr %0& goto quit)
	echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-nodetect" >nul 2>&1  && set _DETECTOR=off
	echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-make detailed template" >nul 2>&1 && (echo DFSPATH, Destination Server ^(just the hostname^), Destination Drive ^(e.g. C-Z$^), Destination Cluster ^(Cluster name^), Destination Cluster Resource, Destination Target Root Path ^(not including DRIVE LETTER:^\^), SRC Server, SRC Drive, SRC Cluster,SRC Root Path>DetailedClusterMoveTemplate.csv&goto quit) 
	echo %1 %2 %3 %4 %5 %6 %7 %8 %9 |find /i "-make simple template" >nul 2>&1 && (echo DFS Source URL, Destination UNC ^( \\^<SERVER^>\^<DRIVE^>$\^<PATH^>^)>SimpleClusterMoveTemplate.csv&goto quit) 
	
	:: trap all incoming variables to a spawned shell and assign all existing elements to
	:: its own variable for safe use later in the script... FYI: the spawned 
	if DEFINED SPAWN (	set _IN_DFSPATH=%1
				set _IN_DSTSERVER=%2
				set _IN_DSTDRV=%3
				set _IN_DSTCLUSTER=%4
				set _IN_DSTCLSTRRES=%5
				set _IN_DSTROOTPATH=%6
				set _IN_SRCSRV=%7
				set _IN_SRCDRV=%8
				set _IN_SRCCLUSTER=%9
				set _IN_SRCROOTPATH=%10)

	
	set _IN1=%1
	set _IN2=%2
	set _ME=%0
	%debug%



	:: the register function tracks the work and will return a RET=2
	:: if a task is already registered... The "read register" function is a modified 
	:: register function that just reads the register section in the registry...
	call :read_register PrepareComplete
	if {%RET%}=={2} (set _STATUS=EXECUTE&& set RET=) else (set _STATUS=PREPARE&&set RET=)

	::::::::::::::::::::::::::::::::::::::::::::::::::::
	::
	:: * Evaluate if cluster mover was called with the parameter file="filename.csv". If this is the case 
	::   the file needs to be processed, skipping the first line (the title headers). The processing of  
	::   the file means that this script will loop itself passing the parameters in CSV file. 
	:: * If the parameter "-nodetect" was included as well, The script expects that all variables will be  
	::   specified in the CSV file.
	:: * For safety reasons SPAWN loops need to be prevented at all costs. Therefore a "SPAWN=1" will be
	::   set for each spawned window so that it, in turn, can not create spawned windows; thus avoiding
	::   a dangerous loop that could bring down a server. This variable will remain in the environment 
	::   for each window after the spawned process exits. The terminal will remain open on the other
	::   hand, for the sake of convenience. 
	:: * An indicative title will also be set for each termianl to avoid confusion.
	::

	if DEFINED SPAWN (set _ME2X=// SPAWN // %_ME% &  goto SETINGS)

	echo %1 |find /i "-map-file" >nul 2>&1 && set _INFILE=%2
		if DEFINED _INFILE for /f "skip=1 tokens=1,2,3,4,5,6,7,8,9 delims=," %%a in (%_INFILE%) do if {%_DETECTOR%}=={off} (set /a count+=1 & start "SPAWN" /min cmd /I /k "set /a SPAWN=1 && %0 %%a %%b %%c %%d %%e %%f %%g %%h %%i -nodetect -dryrun"
			) else (
		set /a count+=1 & start "SPAWN" /min cmd /I /k "set /a SPAWN=1 && %0 %%a %%b")
	color 71 & echo. &echo %_ME% :: ( Launched %count% simultanious tasks...)& echo. &TITLE %_ME% :: ( Launched %count% simultaneous tasks...)
	if DEFINED _INFILE goto quit 
	%debug%


:SETINGS
	::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::  ***             Settings               ***      ::
	::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::
	set temp=c:\temp
	set _LOG=%temp%\%_IN1:~1,100%\%_ME:~1,30%.log
	set _P=q0
	set _LOGDIR=c:\temp


	:: set _RemoteUNC=^<Path to where you keep the management tools^>
	:: Do not quote the path, even if it has spaces in it. It will be taken care of.
	:: 
	set _default_exe_store=\\cs01corp\root\files\corp\IS\Dept\InfrastructureSystems\FilePrint\BIN


	:: List out the files that are require for operation here. Any command used that is 
	:: not a standard command or internal to COMSPEC needs to be listed here. 
	::
       	set _dependencies=Cluster.exe robocopy.exe dfscmd.exe
		

		 
          	::::::::::::::::::::::::::::::::::::::::::::::::::::::
          	::  ***  Verify that dependencies are met ***       ::
          	::::::::::::::::::::::::::::::::::::::::::::::::::::::
          	::
          	::	// post startup code needed  //
          	::
          	::  FYI: 
          	::  Some dependencies are simple executables and can be copied down from a common source...
          	::  Other dependencies are larger applications that may require registered DLL's and can
          	::  not simply be copied down. In the case that this happens, and it is not possible to copy 
          	::  the executable, an error message will be displayed.
          	::
          	%debug%
          	:: goto End_CheckDependencies
          	:CheckDependencies
          		echo Check dependencies: "%_dependencies%"
           
          		for %%d in (%_dependencies%) do (call :VfyPath %%d)
          		if not defined RET goto main
			if not {%RET%}=={0} (set _ERRMSG="An unrecoverable error has occurred..." & call :DispErr !
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

	if defined _DETECTOR (goto EXEC_NODETECT) else (goto EXEC_DEFAULT)
	goto quit



	:EXEC_DEFAULT
		:: Default set of executiion routines. This section will be used unless this 
		if DEFINED SPAWN (set _MEX= %_ME2X% :: MODE = %_STATUS%) else (set _MEX=%_ME% :: MODE = %_STATUS%)
			::: PREPEARE :::
			Title %_MEX% ::
			@call :DisplayBanner %0
			@call :GetPhysicalSourceFromDFS
			@call :GetPhysicalTarget
			@call :GetPathComponents 
			@call :ValidatePhysicalPath "\\%_srcserver%\%_srcdrive%$\%_ServerRootPath%"
			@call :ValidatePhysicalPath %_PhysicalUNCTarget%
			TITLE  %_MEX% :: Please verify the following components:
				echo Press ^<CONTROL^> ^<C^> to exit, Press any key to see the task list& pause & cls 
				@call :DisplayTasks
				SET /P _USER_IN1=Please type "yes" to execute the tasks:  
				if not {%_USER_IN1%}=={yes} (echo You opted out... I am quiting and cleaning up... &	Title %_MEX% :: Skiped &goto quit) 
	
			:: Validate the need to prepare the target UNC path... 
			if {%_STATUS%}=={EXECUTE} (echo Preparation of target is already done... Performing move now...!&goto execute)
		
			@call :PreparePhysicalTarget                              && call :register PrepareComplete
			Title %_MEX% :: DONE
			@goto quit

			::: EXECUTE :::	
			:execute
			Title %_MEX% :: 
			@call :ExecuteMIR_PhysicalTarget run1
			@call :ExecuteDestroyDFS
			@call :ExecuteDestroyClusterShare
			@call :ExecuteMIR_PhysicalTarget run2
			@call :ExecuteClusterResourceShare
			@call :ExecuteDFSPointerSetup
			Title %_MEX% :: DONE
			@goto quit
	:END_EXEC_DEFAULT
	
	
	:EXEC_NODETECT
		if DEFINED SPAWN (set _MEX= %_ME2X% :: MODE = %_STATUS%) else (set _MEX=%_ME% :: MODE = %_STATUS%)
			::: PREPARE :::
			Title %_MEX% ::
			@call :DisplayBanner %0
			@call :AssignComponentsFromStdIn
			@call :ValidatePhysicalPath "\\%_srcserver%\%_srcdrive%$\%_ServerRootPath%"
			@call :ValidatePhysicalPath %_PhysicalUNCTarget%
			TITLE  %_MEX% :: Please verify the following components:
				echo Press ^<CONTROL^> ^<C^> to exit, Press any key to see the task list& pause & cls 
				@call :DisplayTasks
				SET /P _USER_IN1=Please type "yes" to execute the tasks:  
				if not {%_USER_IN1%}=={yes} (echo You opted out... I am quiting and cleaning up... &	Title %_MEX% :: Skiped &goto quit) 
	
			:: Validate the need to prepare the target UNC path... 
			if {%_STATUS%}=={EXECUTE} (echo Preparation of target is already done... Performing move now...!&goto execute)
		
			@call :PreparePhysicalTarget                              && call :register PrepareComplete
			Title %_MEX% :: DONE
			@goto quit

	:END_EXEC_NODETECT

	
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::           Sub Routines                   ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DisplayBanner
	setlocal
	Title %_MEX% :: (%0)
	color 1e
	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ                              Start                                        บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo %DATE% : %TIME%
	echo I am: %1 Invoked by: %CMDCMDLINE%
	echo.
	echo  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	echo.
	endlocal
	goto eof
:End_DisplayBanner




:AssignComponentsFromStdIn
	Title %_MEX% :: (%0)
	:: This routine will be called if %0 was called with explicit parameters and 
	:: the -nodetect parameter.
	::
	::Make sure that we were passed at leas 5 elements from the INFILE
	::if {%5}=={} (set _ERRMSG=Failed to execute %0!! Please check the syntax of the %_INFILE%& goto DispErr)

	:: assign default values to all variable that we can...
	set _srcserver=%_IN_SRCSRV%
	set _srcdrive=%_IN_SRCDRV%
	set _srccluster=%_IN_SRCCLUSTER%
	set _dstserver=%_IN_DSTSERVER%
	set _dstdrive=%_IN_DSTDRV%
	set _dstcluster=%_IN_DSTCLUSTER%
	set _CLUSTER-ShareNAME=%_IN_DSTCLSTRRES%
	set _ServerRootPath=%_IN_DSTROOTPATH%
		echo %_dstdrive% find /i "$"  >nul 2>&1 && set %_srcdrive%=%_dstdrive:~0,1%
		echo %_dstdrive% find /i ":"  >nul 2>&1 && set %_srcdrive%=%_dstdrive:~0,1%
		echo %_dstdrive% find /i "$"  >nul 2>&1 && set %_dstdrive%=%_dstdrive:~0,1%
		echo %_dstdrive% find /i ":"  >nul 2>&1 && set %_dstdrive%=%_dstdrive:~0,1%
	set _PhysicalUNCTarget=\\%_dstserver%\%_dstdrive%$\%_ServerRootPath%
	set _PhysicalUNCSrc=\\%_srcserver%\%_crcdrive%$\%_srcServerRootPath%

	
	echo Source server        = %_srcserver%
	echo Source Drive         = %_srcdrive%
	echo Source Cluster       = %_srccluster%
	echo Destination Server   = %_dstserver%
	echo Destination Drive    = %_dstdrive%
	echo Destination Cluster  = %_dstcluster%
	echo Cluster Resource     = %_CLUSTER-ShareNAME%
	echo Server Root Path     = %_ServerRootPath%
	echo Physical Target Path = %_PhysicalUNCTarget%
	echo Physical Source Path = %_PhysicalUNCSrc%

	pause
	goto eof
:END_AssignComponentsFromStdIn




:DisplayTasks
	Title %_MEX% :: (%0) :: Is this what you want to do?

	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ                              Task List                                    บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	if {%_STATUS%}=={EXECUTE} (echo    Prepare: [DONE]) else (echo    Prepare: [PENDING...])
	echo    1 - copy all data from: \\%_srcserver%\%_srcdrive%$\%_ServerRootPath%
	echo    2 - to                : %_PhysicalUNCTarget%
	echo.
	if {%_STATUS%}=={EXECUTE} (echo    Execute: [PENDING...]) else (echo    Execute: [PENDING...])    
	echo    Pre - Presynchronize the 2 locations
	echo    1 - Remove DFS pointer: %_IN1%
	echo    2 - Remove file share : %_DFSPhysicalPath%
	echo    3 - synchronize       :
	echo            \\%_srcserver%\%_srcdrive%$\%_ServerRootPath%
	echo                         and
	echo            %_PhysicalUNCTarget%
	echo    4 - Create file share : \\%_dstserver%\%_CLUSTER-ShareNAME%
	echo    5 - Create DFS pointer: %_IN1%
	echo.
	echo.  ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

	goto eof

:End_DisplayTasks
	



:ExecuteDestroyDFS
	Title %_MEX% :: (%0)
	setlocal
	:: remove the DFS 
	call :register  %0
		if {%RET%}=={2} (echo %0 already done, skipping... &goto eof)
		%_dry% dfscmd /unmap %_IN1%	||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
	endlocal & call :register  %0&goto eof
:End_ExecuteDestroyDFS





:ExecuteClusterResourceShare
	Title %_MEX% :: (%0)
	setlocal
	:: Share the new resource using the cluster command...
	::
	call :register  %0
		if {%RET%}=={2} (echo %0 already done, skipping... &goto eof)
		%_dry% cluster /cluster:%_DSTCLUSTERNAME% res "%_dstserver% - %_CLUSTER-ShareNAME%" /create /group:"%_dstserver%" /type:"file share" ||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
		%_dry% cluster /cluster:%_DSTCLUSTERNAME% res "%_dstserver% - %_CLUSTER-ShareNAME%" /priv path="%_dstdrive%:\%_ServerRootPath%"  ||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
		%_dry% cluster /cluster:%_DSTCLUSTERNAME% res "%_dstserver% - %_CLUSTER-ShareNAME%" /priv sharename="%_CLUSTER-ShareNAME%"  ||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
		%_dry% cluster /cluster:%_DSTCLUSTERNAME% res "%_dstserver% - %_CLUSTER-ShareNAME%" /priv security="EveryOne",grant,F:security ||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
		%_dry% cluster /cluster:%_DSTCLUSTERNAME% res "%_dstserver% - %_CLUSTER-ShareNAME%" /adddep:"%_dstserver% - Network Name" ||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
		%_dry% cluster /cluster:%_DSTCLUSTERNAME% res "%_dstserver% - %_CLUSTER-ShareNAME%" /adddep:"Disk %_dstdrive%:" ||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
		%_dry% cluster /cluster:%_DSTCLUSTERNAME% res "%_dstserver% - %_CLUSTER-ShareNAME%" /on ||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
		
	endlocal & call :register  %0&goto eof
:End_ExecuteClusterResourceShare





:ExecuteDFSPointerSetup
	Title %_MEX% :: (%0)
	setlocal
	:: Point DFS to the new source...
	:: 
	::
 	call :register  %0
		if {%RET%}=={2} (echo %0 already done, skipping... & endlocal & goto eof)
		%_dry% dfscmd /map %_IN1% \\%_dstserver%\%_CLUSTER-ShareNAME%	||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
	endlocal & call :register  %0&goto eof
:End_ExecuteDFSPointerSetup




:PreparePhysicalTarget
	Title %_MEX% :: (%0)
	setlocal
	:: copy all files from source to destination...
	::
	call :register  %0
		if {%RET%}=={2} (echo %0 already done, skipping... & endlocal & goto eof)
		for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set _newdate=%%d-%%b-%%c
		set _LOGFILE=%_newdate%-%_dstserver%-%_CLUSTER-ShareNAME%-PREPARE.log
		set _LOG=%_LOGDIR%\%_LOGFILE%
		%_dry% if not exist %_PhysicalUNCTarget% mkdir %_PhysicalUNCTarget%
		%_dry% robocopy "\\%_srcserver%\%_srcdrive%$\%_ServerRootPath%" "%_PhysicalUNCTarget%" *.* /e /copyall /LOG+:"%_LOG%"
	endlocal & call :register  %0&goto eof
:End_PreparePhysicalTarget



:ExecuteMIR_PhysicalTarget
	Title %_MEX% :: (%0)
	setlocal
	call :register  %0-%1
		if {%RET%}=={2} (echo %0 already done, skipping... & endlocal & goto eof)
		:: Resynchronize the target and the source... 
		::
		for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set _newdate=%%d-%%b-%%c
		for /f "tokens=1-4 delims=\" %%i in (%_IN2%) do set _LOGFILE=%_newdate%-%_ME%-MIR%2-%%a_%%b_%%c_%%d_%RANDOM%.log
		set _LOG=%_LOGDIR%\%_LOGFILE%
		%_dry% robocopy  "\\%_srcserver%\%_srcdrive%$\%_ServerRootPath%" %_PhysicalUNCTarget% *.* /mir /LOG+:"%_LOG%"
  	endlocal& call :register  %0&goto eof
:End_ExecuteMIR_PhysicalTarget





:ExecuteDestroyClusterShare
	Title %_MEX% :: (%0)

	:: Shut off the cluster resource... The naming convention can be confusing and
	:: mistaken for CLUSTER.EXE syntax. The command below will turn off the Cluster resource
	:: "share"... the name of the cluster server is in the physical path that we got from 
	:: the DFS source parameter passed to this script. 
	::
	::          	
	::          	*cluster node*             *naming convention*
	::  		                name               server   -      resource name
	::
	call :register  %0
		if {%RET%}=={2} (echo %0 already done, skipping... &goto eof)
		set ERRORLEVEL=
		%_dry% cluster /cluster:%_SRCCLUSTERNAME% res "%_srcserver% - %_CLUSTER-ShareNAME%" /Off /Wait:15 ||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
		%_dry% cluster /cluster:%_SRCCLUSTERNAME% res "%_srcserver% - %_CLUSTER-ShareNAME%" /delete ||(set _ERRMSG=Failed to execute %0!!& goto DispErr)
	call :register  %0&goto eof
:End_ExecuteDestroyClusterShare







:GetPathComponents
	Title %_MEX% :: (%0)

	:: Grab the Name of the source server from the physical path 
	:: of the DFS share...
	::
	for /f "delims=\ " %%i in ("%_DFSPhysicalPath%") do set _srcserver=%%i
	set _srcdrive=%_srcserver:~-1%

	echo.
	echo Source Server      = %_srcserver%
	echo Source Drive       = %_srcdrive%

	:: Grab the Destination server and the destination drive from 
	:: the UNC path given...
	::
	for /f "delims=\" %%i in ("%_PhysicalUNCTarget%") do set _dstserver=%%i
	for /f "delims=\ tokens=2" %%i in ("%_PhysicalUNCTarget%") do set _token2=%%i
	set _dstdrive=%_token2:~0,1%
	set _GROUPNUMBER=%_dstserver:~-1% 
	echo Destination Server = %_dstserver%
	echo Destination Drive  = %_dstdrive%
	if {%_dstserver:~2,3%}=={%_P%} (set _DSTCLUSTERNAME=%_dstserver:~0,-2%) else (set _DSTCLUSTERNAME=%_dstserver:~0,2%%_P%%_dstserver:~3,3%)
	echo Destination Cluster= %_DSTCLUSTERNAME%
	set _GROUPNAME=%_srcserver%

	if {%_srcserver:~2,3%}=={%_P%} (set _SRCCLUSTERNAME=%_srcserver:~0,-2%) else (set _SRCCLUSTERNAME=%_srcserver:~0,2%%_P%%_srcserver:~3,3%)
	echo Source Cluster     = %_SRCCLUSTERNAME%


	:: Grab the DFS name from the from the DFS path given...
	::
	for /f "delims=\" %%i in ("%_IN1%") do set _DFSServer=%%i
	echo DFS Server         = %_DFSServer%

	:: Grab the name of the cluster node from the detected physical path of 
	:: the source...
	::	
	for /f "delims=\ tokens=2" %%i in ("%_DFSPhysicalPath%") do set _CLUSTER-ShareNAME=%%i
	echo Cluster Resource   = %_CLUSTER-ShareNAME%

	for /f "delims=$ tokens=2" %%i in ("%_PhysicalUNCTarget%") do set _ServerRootPath=%%i
	set _ServerRootPath=%_ServerRootPath:~1,100%
	echo Target Path        = %_ServerRootPath%
	
	
	call :register  %0&goto eof
:End_GetPathComponents






:CopyFilesLocaly
	Title %_MEX% :: (%0)

	setlocal 
	title %0
	:: Call "the register" to determines if this procedure needs to 
	:: run. 2 = no and 0 = yes
	:: @call :register %0 
		if {%RET%}=={2} (endlocal & goto eof)
		%_dry% if not exist %_local% MD %_local%
		%_dry% xcopy "%_RemoteUNC%" %_local% /v /r /y /u /d /i
	
	call :register  %0& endlocal & goto eof

:End_CopyFilesLocaly






:GetPhysicalSourceFromDFS
	Title %_MEX% :: (%0)

	echo finding the true target from DFS Parameter...
	echo I got DFS path:              %_IN1% 
	set _count=
	mkdir %temp%\%_IN2% >nul 2>&1 & set _MR=%temp%\%_IN2%\%RANDOM%
	dfscmd /view %_IN1% /full|find /i /n "%_IN1%" >"%_MR%"
	for /f "delims=[] tokens=1" %%i in (%_MR%) do (call :GetNextLineValue %%i)

	goto eof
	:GetNextLineValue
		set _LineNUM=%1
		set _DFSPhysicalPath=
		for /f "skip=%_LineNUM%" %%i in ('dfscmd /view %_IN1% /full') do (set _DFSPhysicalPath=%%i)
		if {%_DFSPhysicalPath%}=={} echo Dfs physical path not found!!! "%_DFSPhysicalPath%" &pause
		echo I found DFS physical path:   %_DFSPhysicalPath%
	
	call :register  %0&goto eof

:End_GetPhysicalSourceFromDFS






:GetPhysicalTarget
	Title %_MEX% :: (%0)

	if not defined _IN2 (set _ERRMSG=Target Value not provided & goto DispErr)
	
	if {%_IN2:~0,2%}=={\\} (set _PhysicalUNCTarget=%_IN2%
		) else (
		echo physical target is not a valid UNC format...) 
	if defined _PhysicalUNCTarget echo I got physical target:       %_PhysicalUNCTarget%	
	
	call :register  %0&goto eof

:End_GetPhysicalTarget






:ValidatePhysicalPath
	Title %_MEX% :: (%0)

	setlocal
		echo.
		echo Validating physical source from DFS...
		:: Set the default return variable to failure...
		::
		set /a _RET=-1
		:: Only set RET to 0 (OK) if we can write and read to the location...
		::
		if not exist %1 mkdir %1 ||(echo The path %1 does not seem to exist... ) && (echo path %1 seems to exist...)
		echo !>%1\%_ME:~1,30%.flg && type %1\%_ME:~1,30%.flg |find /i "!" >nul&& set /a _RET=0
		echo.
		if {%_RET%}=={0} (echo %1 is validated... [RW]) else (echo path %1 is not valid!...[RW])
	call :register  %0& endlocal & set _RET=%_RET% & goto eof
		
:End_ValidatePhysicalPath





:EnumeratedfsOutput
	Title %_MEX% :: (%0)

		:: This my be a useful module so I am keeping it around...
		echo enumerating all the DFS pointers...
		for /f "skip=2" %%i in ('dfscmd /view %_IN1% /full') do (call :EnumerateOutput %%i)
		echo "%_MyDFSPath%"
		goto eof
			:EnumerateOutput
				title Processing ::  %1 
				echo %1|find /i "%_IN1%"&& set _MyDFSPath=%_IN1%
				set /a _count+=1
				if not defined _toggle set /a _toggle=1 
				if not {%_toggle%}=={1} (set /a _toggle=1) else (set /a _toggle=0)
				%trace% Toggle value is set to:%_toggle%
				%trace% reading line: %_count% Name:  "%1"
				echo %_count% %1>> %temp%%_IN1:~1,100%\%_ME:~1,30%.log
		call :register  %0&goto eof
:End_EnumeratedfsOutput

				
		

	
	



:VfyPath
	Title %_MEX% :: (%0)

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






:get
	Title %_MEX% :: (%0)

	:: Copy Install source files locally...
		xcopy "%_installpath%\%1" "%temp%"
		call :register  %0&goto eof

:clean
	Title %_MEX% :: (%0)

	:: Clean up local cache of source files
		del /f /s /q %temp%/%1
		call :register  %0&goto eof

:register
	Title %_MEX% :: (%0)

	:: Look in the registry "hklm\software\" to see if the subsection
	:: passed to this procedure has been run already. If the passed argument is in the registry
	:: a return variable of RET=2 is passed back to parent procedure. If the argument is not found a return variable
	:: of RET=0 is returned.
	setlocal
		set _item=%1
		reg query "hklm\software\_aniara\%_ME%\%_IN1:~2,100%\%_item%" >nul 2>&1 && (set RET=2)|| (reg add "hklm\software\_aniara\%_ME%\%_IN1:~2,100%\%_item%" >nul 2>&1 & set ret=0)
	endlocal & set RET=%RET%& goto eof

:read_register
	Title %_MEX% :: (%0)

	:: Look in the registry "hklm\software\" to see if the subsection
	:: passed to this procedure is present. If it is, a return variable of RET=2 will be returned. 
	setlocal
		set _item=%1
		reg query "hklm\software\_aniara\%_ME%\%_IN1:~2,100%\%_item%" >nul 2>&1 && (set RET=2)|| (set ret=1)
	endlocal & set RET=%RET%& goto eof

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::            ERROR handling Below          ::::::::::::::::::::::
::::::::::::::                                          ::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Get_dep
	Title %_ME% :: (%0)

	setlocal
		set RET=0
		xcopy "%_default_exe_store%\%1" "%temp%" ||set RET=-1
	endlocal &set RET=%RET%
	call :register  %0&goto eof

:synerr
	echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo บ Syntax                                                             ...    บ
	echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo  The sytax of this command is:
	echo.
	echo  %1 ^<DFS path^> ^<Destination UNC^>
	echo         ( e.g. \\^<SERVER^>\^<DRIVE^>$\^<PATH^>) 
	echo. 
	echo  Alternatively:
	echo. 
	echo  %1 -Map-File=^<MyFile.CSV^> 
	echo        (where "MyFile.CSV" is a source and destination list)
	echo.
	echo  %1 -make detailed template
	echo  %1 -make simple template
	echo.
	goto eof

:DispErr
set _
pause
	%_dry% if not defined debug cls
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
	for /f "delims== tokens=1" %%i in ('set _') do (set %%i=) >nul 2>&1 &endlocal & popd 
	set trace= &set debug=


:eof
