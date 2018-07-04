# CMD-Scripts

## Synopsis
These are a collection of administrative command scripts created to run in the Windows terminal. These should run on any version of windows even the NT era (well mostly) with no need for Windows Shell scripting host or anything else. This is one of the advantages of using the CMD or BATCH scripting as opposed to other addon interpreters; PERL, REX, PS are great but you do not know that every system has this available for sure.

As instructed by Tim Hill in the book "Windos NT shell scripting", these scripts make extensive use of FÖR loops and calling sub routines to make the code manageable and limit goofups is several people are touching them at the same time. 

### Example 1
```
for %%d in (%_dependencies%) do (call :VfyPath %%d)
	if not {%RET%}=={0} (set _ERRMSG="An unrecoverable error has occured..." & call :DispErr !
			) else (
			goto MAIN)
endlocal & goto eof
``` 
 
### Example 2
And sub routines use SETLOCAL and ENDLOCAL as well as sometimes PUSH and POPD where relevant to maintain operability. 
```
:VfyPath
   setlocal
   set _LocalVfy=%~$PATH:1
   if {"%_LocalVfy%"}=={""} (
	call :Get_dep %1
	) else (
	echo Dependency %1 satisfied....)
	if defined RET if not {%RET%}=={0} (set _ERRMSG="File %1 is not in the PATH!" & call :DispErr !)
   set _LocalVfy=
   endlocal & goto eof
:End_VfyPath
 ```

## Motivation
These scripts are added and somewhat mainetained here so that someone else may find them useful. 

## Installation

Simply place these scripts in a handy location.   

## License
GPL v3 Please 
So kindly share back cool changes that you make so that othesrs may enjoy. 
